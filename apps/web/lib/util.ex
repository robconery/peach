defmodule Redfour.Web.Util do
  use Number

  def money(val) do
    Number.Currency.number_to_currency val/100
  end

  def markdown(md) do
    Earmark.to_html(md)
  end
end
