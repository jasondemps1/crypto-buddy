defmodule Streamer.Binance do
  use WebSockex
  require Logger

  @stream_endpoint "wss://stream.binance.com:9443/ws/"

  def start_link(symbol) do
    symbol = String.downcase(symbol)

    WebSockex.start_link(
      "#{@stream_endpoint}#{symbol}@trade",
      __MODULE__,
      nil
    )
  end

  def handle_frame({_type, msg}, state) do
    # IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    case Jason.decode(msg) do
      {:ok, event} -> process_event(event)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end

    {:ok, state}
  end

  defp process_event(%{"e" => "trade"} = event) do
    trade_event = %Streamer.Binance.TradeEvent{
      :event_type => event["e"],
      :event_time => event["E"],
      :symbol => event["s"],
      :trade_id => event["t"],
      :price => event["p"],
      :quantity => event["q"],
      :buyer_order_id => event["b"],
      :seller_order_id => event["a"],
      :trade_time => event["T"],
      :buyer_market_maker => event["m"]
    }

    Logger.debug(
      "Trade event received" <>
        "#{trade_event.symbol}@#{trade_event.price}"
    )

    #Naive.send_event(trade_event)
    Phoenix.PubSub.broadcast(
      Streamer.PubSub,
      "TRADE_EVENTS:#{trade_event.symbol}",
      trade_event
    )
  end

  # Not sending any messages to Binance, we dont need this right now.
  # def handle_cast({:send, {type, msg} = frame}, state) do
  # IO.puts "Sending #{type} frame with payload: #{msg}"
  # {:reply, frame, state}
  # end
end
