defmodule Peach.Fulfillment.DummyMailServer do

  def send(%Peach.Mailer{} = mailer) do
    mailer = %{mailer | sent_at: Peach.Fulfillment.Db.now_iso}
    {:ok, mailer}
  end


end
