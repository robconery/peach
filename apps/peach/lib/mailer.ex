defmodule Peach.Mailer do
  import Moebius.DocumentQuery
  alias Peach.Fulfillment.Db

  defstruct [
    key: nil,
    subject: nil,
    body: nil,
    to: nil,
    sent_at: nil,
    logs: []
  ]

  def prepare(key: key, order_key: order_key, to: email, name: name, site_name: site_name, info: info) do
    mailer = db(:mailers) |> contains(key: key) |> Db.first
    body = Earmark.to_html(mailer.template)
    body
      |> String.replace("{{name}}", name)
      |> String.replace("{{site_name}}", site_name)
      |> String.replace("{{info}}", info)
      |> String.replace("{{key}}", order_key)

    subject = String.replace(mailer.subject, "{{key}}", order_key)

    %Peach.Mailer{
      key: key,
      subject: subject,
      to: email,
      logs: [%{date: Db.now_iso, entry: "Mailer prepared"}]
    }
  end

  def find(key: key),  do: Db.get_mailer(key: key)

  def send(%Peach.Mailer{to: to, subject: subject} = mailer) when not to == nil and not subject == nil do
    service = Application.get_env(:fulfillment, :mailer)
    %{mailer | logs: List.insert_at(mailer.logs, -1, "Preparing to send"), sent_at: Db.now_iso}
      |> service.send
  end
end
