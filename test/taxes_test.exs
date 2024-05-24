defmodule TaxesTest do
  use ExUnit.Case
  doctest Taxes

  describe "calculate/2" do
    test "should calculate inclusive tax" do
      taxes = [
        %{
          title: "VAT",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent
        }
      ]

      assert Taxes.calculate(120.00, taxes) == {:ok, 100.00, 120.00, [{"VAT", 20.00}]}
      assert Taxes.calculate(100.00, taxes) == {:ok, 83.33, 100.00, [{"VAT", 16.67}]}
    end

    test "should calculate inclusive tax for 149.00" do
      taxes = [
        %{
          title: "VAT",
          rate: 15.00,
          is_inclusive: true,
          logic: :percent
        }
      ]

      assert Taxes.calculate(149.00, taxes) == {:ok, 129.56, 149.0, [{"VAT", 19.44}]}
    end

    test "should calculate tax with rate provided as integer" do
      taxes = [
        %{
          title: "VAT",
          rate: 2000,
          is_inclusive: true,
          logic: :percent
        }
      ]

      assert Taxes.calculate(120.00, taxes) == {:ok, 100.00, 120.00, [{"VAT", 20.00}]}
      assert Taxes.calculate(100.00, taxes) == {:ok, 83.33, 100.00, [{"VAT", 16.67}]}
    end

    test "should calculate tax with rate provided as string" do
      taxes = [
        %{
          title: "VAT",
          rate: "20.00",
          is_inclusive: true,
          logic: :percent
        }
      ]

      assert Taxes.calculate(120.00, taxes) == {:ok, 100.00, 120.00, [{"VAT", 20.00}]}
      assert Taxes.calculate(100.00, taxes) == {:ok, 83.33, 100.00, [{"VAT", 16.67}]}
    end

    test "should calculate several inclusive percent taxes" do
      taxes = [
        %{
          title: "VAT",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent
        },
        %{
          title: "City Tax",
          rate: 10.00,
          is_inclusive: true,
          logic: :percent
        }
      ]

      assert Taxes.calculate(130.00, taxes) ==
               {:ok, 100.00, 130.00, [{"City Tax", 10.00}, {"VAT", 20.00}]}
    end

    test "should calculate inclusive percent and per_booking on raw taxes" do
      taxes = [
        %{
          title: "City Tax",
          rate: 10.00,
          is_inclusive: true,
          logic: :per_booking,
          taxes: [
            %{
              title: "VAT",
              rate: 20.00,
              is_inclusive: true,
              logic: :percent
            }
          ]
        }
      ]

      assert Taxes.calculate(130.00, taxes) ==
               {:ok, 100.00, 130.00, [{"City Tax", 10.00}, {"VAT", 20.00}]}
    end

    test "should calculate inclusive percent and per_booking on net taxes" do
      taxes = [
        %{
          title: "VAT",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          taxes: [
            %{
              title: "City Tax",
              rate: 10.00,
              is_inclusive: true,
              logic: :per_booking
            }
          ]
        }
      ]

      assert Taxes.calculate(130.00, taxes) ==
               {:ok, 98.33, 130.00, [{"VAT", 21.67}, {"City Tax", 10.0}]}
    end

    test "should calculate excluded per_booking tax" do
      taxes = [
        %{
          title: "Service Fee",
          rate: 10.00,
          is_inclusive: false,
          logic: :per_booking
        }
      ]

      assert Taxes.calculate(100.00, taxes) == {:ok, 100.00, 110.00, [{"Service Fee", 10.0}]}
    end

    test "should calculate excluded per_person tax" do
      taxes = [
        %{
          title: "Service Fee",
          rate: 10.00,
          is_inclusive: false,
          logic: :per_person
        }
      ]

      assert Taxes.calculate(100.00, taxes, 2, 1) ==
               {:ok, 100.00, 110.00, [{"Service Fee", 10.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 2) ==
               {:ok, 100.00, 120.00, [{"Service Fee", 20.0}]}
    end

    test "should calculate excluded per_person_per_night tax" do
      taxes = [
        %{
          title: "Service Fee",
          rate: 10.00,
          is_inclusive: false,
          logic: :per_person_per_night
        }
      ]

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 1) ==
               {:ok, 100.00, 110.00, [{"Service Fee", 10.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 1) ==
               {:ok, 100.00, 120.00, [{"Service Fee", 20.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 2) ==
               {:ok, 100.00, 120.00, [{"Service Fee", 20.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 2) ==
               {:ok, 100.00, 140.00, [{"Service Fee", 40.0}]}
    end

    test "should calculate several excluded taxes" do
      taxes = [
        %{
          title: "Service Fee",
          rate: 10.00,
          is_inclusive: false,
          logic: :per_person_per_night
        },
        %{
          title: "Credit Card Fee",
          rate: 3.00,
          is_inclusive: false,
          logic: :percent
        }
      ]

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 1) ==
               {:ok, 100.00, 113.00, [{"Service Fee", 10.0}, {"Credit Card Fee", 3.00}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 1) ==
               {:ok, 100.00, 123.00, [{"Service Fee", 20.0}, {"Credit Card Fee", 3.00}]}

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 2) ==
               {:ok, 100.00, 123.00, [{"Service Fee", 20.0}, {"Credit Card Fee", 3.00}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 2) ==
               {:ok, 100.00, 143.00, [{"Service Fee", 40.0}, {"Credit Card Fee", 3.00}]}
    end

    test "should calculate several excluded tax with nested taxes" do
      taxes = [
        %{
          title: "Credit Card Fee",
          rate: 3.00,
          is_inclusive: false,
          logic: :percent,
          taxes: [
            %{
              title: "Service Fee",
              rate: 10.00,
              is_inclusive: false,
              logic: :per_person_per_night
            }
          ]
        }
      ]

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 1) ==
               {:ok, 100.00, 113.30, [{"Credit Card Fee", 3.30}, {"Service Fee", 10.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 1) ==
               {:ok, 100.00, 123.60, [{"Credit Card Fee", 3.60}, {"Service Fee", 20.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 1, 1, 2) ==
               {:ok, 100.00, 123.60, [{"Credit Card Fee", 3.60}, {"Service Fee", 20.0}]}

      assert Taxes.calculate(100.00, taxes, 2, 2, 1, 2) ==
               {:ok, 100.00, 144.20, [{"Credit Card Fee", 4.20}, {"Service Fee", 40.0}]}
    end

    test "should calculate Thai provincial tax case" do
      taxes = [
        %{
          title: "Provincial tax",
          rate: 1.00,
          is_inclusive: true,
          logic: :percent
        },
        %{
          title: "VAT",
          rate: 7.00,
          is_inclusive: true,
          logic: :percent,
          taxes: [
            %{
              title: "Service Charge",
              rate: 10.00,
              is_inclusive: true,
              logic: :percent
            }
          ]
        }
      ]

      assert Taxes.calculate(3400.00, taxes) ==
               {:ok, 2864.36, 3400.00,
                [
                  {"VAT", 220.56},
                  {"Service Charge", 286.44},
                  {"Provincial tax", 28.64}
                ]}
    end

    test "should calculate USA 2 level tax case" do
      taxes = [
        %{
          title: "10% City Tax",
          rate: 10.00,
          is_inclusive: false,
          logic: :percent,
          taxes: [
            %{
              title: "$10 cleaning fee",
              rate: 10.00,
              is_inclusive: false,
              logic: :per_booking
            },
            %{
              title: "10% reservation fee",
              rate: 10.00,
              is_inclusive: false,
              logic: :percent
            }
          ]
        },
        %{
          title: "3% TBID Tax",
          rate: 3.00,
          is_inclusive: false,
          logic: :percent,
          taxes: [
            %{
              title: "$10 cleaning fee",
              rate: 10.00,
              is_inclusive: false,
              logic: :per_booking
            },
            %{
              title: "10% reservation fee",
              rate: 10.00,
              is_inclusive: false,
              logic: :percent
            }
          ]
        }
      ]

      assert Taxes.calculate(100.00, taxes) ==
               {:ok, 100.00, 135.60,
                [
                  {"3% TBID Tax", 3.6},
                  {"$10 cleaning fee", 10.0},
                  {"10% reservation fee", 10.0},
                  {"10% City Tax", 12.0}
                ]}
    end
  end

  describe "calculate_with_dates/3" do
    test "should calculate taxes with dates" do
      taxes = [
        %{
          title: "VAT",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent
        }
      ]

      dates = %{
        ~D[2020-01-01] => 100,
        ~D[2020-01-02] => 100
      }

      assert Taxes.calculate_with_dates(dates, taxes) == {:ok, 166.66, 200.00, [{"VAT", 33.34}]}
    end

    test "should calculate taxes and apply max_nights and skip_nights filters" do
      taxes = [
        %{
          title: "VAT for 1 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          max_nights: 1
        },
        %{
          title: "VAT from 2 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          skip_nights: 1
        }
      ]

      dates = %{
        ~D[2020-01-01] => 100,
        ~D[2020-01-02] => 100
      }

      assert Taxes.calculate_with_dates(dates, taxes) ==
               {:ok, 166.66, 200.00, [{"VAT for 1 night", 16.67}, {"VAT from 2 night", 16.67}]}
    end

    test "should calculate taxes and apply applicable_* filters" do
      taxes = [
        %{
          title: "VAT for 1 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_before: ~D[2019-12-31]
        },
        %{
          title: "VAT from 2 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_after: ~D[2020-01-01]
        }
      ]

      dates = %{
        ~D[2019-12-31] => 100,
        ~D[2020-01-01] => 100
      }

      assert Taxes.calculate_with_dates(dates, taxes) ==
               {:ok, 166.66, 200.00, [{"VAT from 2 night", 16.67}, {"VAT for 1 night", 16.67}]}
    end

    test "should calculate taxes and apply applicable_date_ranges filters" do
      taxes = [
        %{
          title: "VAT for 1 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_date_ranges: [%{after: nil, before: ~D[2019-12-31]}]
        },
        %{
          title: "VAT from 2 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_date_ranges: [%{after: ~D[2020-01-01], before: nil}]
        },
        %{
          title: "VAT for far future",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_date_ranges: [%{after: ~D[2030-01-01], before: ~D[2030-12-31]}]
        }
      ]

      dates = %{
        ~D[2019-12-31] => 100,
        ~D[2020-01-01] => 100
      }

      assert Taxes.calculate_with_dates(dates, taxes) ==
               {:ok, 166.66, 200.00, [{"VAT from 2 night", 16.67}, {"VAT for 1 night", 16.67}]}
    end

    test "should calculate taxes and ingnote empty applicable_date_ranges filters" do
      taxes = [
        %{
          title: "VAT for 1 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_date_ranges: nil
        },
        %{
          title: "VAT from 2 night",
          rate: 20.00,
          is_inclusive: true,
          logic: :percent,
          applicable_date_ranges: []
        }
      ]

      dates = %{
        ~D[2019-12-31] => 100,
        ~D[2020-01-01] => 100
      }

      assert Taxes.calculate_with_dates(dates, taxes) ==
               {:ok, 142.84, 200.00, [{"VAT from 2 night", 28.58}, {"VAT for 1 night", 28.58}]}
    end
  end
end
