defmodule Server.TheCreator do
  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator
      @functionName []
      @errorName []
      @before_compile Server.TheCreator
    end
  end

  defmacro my_get(description, do: block) do
    function_name = String.to_atom("my_get " <> description)

    quote do
      @functionName [unquote(function_name) | @functionName]
      def unquote(function_name)(), do: IO.inspect(unquote(block))
    end
  end

  defmacro my_error(code, content) do
    error_name = String.to_atom("my_error " <> Integer.to_string(code))

    quote do
      @errorName [unquote(error_name) | @errorName]
      def unquote(error_name)(), do: IO.inspect(unquote(code: code, content: content))
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run do
        Enum.each(@functionName, fn name ->
          IO.puts("Running #{name}")
          apply(__MODULE__, name, [])
        end)

        Enum.each(@errorName, fn error ->
          IO.puts("Running #{error}")
          apply(__MODULE__, error, [])
        end)
      end
    end
  end
end
