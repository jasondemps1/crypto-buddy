defmodule Streamer.Binance do
  use WebSockex

  @stream_endpoint "wss://stream.binance.com:9443/ws/"

  def start_link(symbol) do
    symbol = String.downcase(symbol)

    WebSockex.start_link(
      "#{@stream_endpoint}#{symbol}@trade",
      __MODULE__,
      nil)
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  # Not sending any messages to Binance, we dont need this right now.
  #def handle_cast({:send, {type, msg} = frame}, state) do
    #IO.puts "Sending #{type} frame with payload: #{msg}"
    #{:reply, frame, state}
  #end
end
