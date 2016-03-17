defmodule Peach.Util do

  def now_iso do
    {:ok, date} = Timex.Date.now |> Timex.DateFormat.format("%Y-%m-%d %H:%M:%S%z", :strftime)
    date
  end

end
