require "application_system_test_case"

class MoneyTest < ApplicationSystemTestCase
  setup do
    @money = money(:one)
  end

  test "visiting the index" do
    visit money_url
    assert_selector "h1", text: "Money"
  end

  test "creating a Money" do
    visit money_url
    click_on "New Money"

    click_on "Create Money"

    assert_text "Money was successfully created"
    click_on "Back"
  end

  test "updating a Money" do
    visit money_url
    click_on "Edit", match: :first

    click_on "Update Money"

    assert_text "Money was successfully updated"
    click_on "Back"
  end

  test "destroying a Money" do
    visit money_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Money was successfully destroyed"
  end
end
