defmodule Peach.Mailer.Template do
  defstruct [
    site_name: nil,
    key: nil,
    info: nil,
    from_name: nil,
    site_email: nil
  ]

  def create_from_order(%Peach.Accounting.SalesOrder{key: key, items: items} = order) do
    %Peach.Mailer.Template{
      site_name: "Red:4 Store",
      key: order.key,
      info: Order.items_to_html_list(order),
      from_name: "Rob Conery",
      site_email: "store@redfour.io"
    }
  end

  def apply_to_mailer(%Peach.Mailer{} = mailer, args) when is_list(args) do
    EEx.eval_string mailer.template, args
  end
end
