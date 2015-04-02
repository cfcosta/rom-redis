module ROM
  module Redis
    module Serialization
      extend self

      @adapters = {}
      @default_adapter = :json_native

      def register(name, adapter)
        @adapters[name] = adapter
      end

      def unregister(name)
        @adapters.delete(name)
      end

      def use(name)
        @adapters.fetch(name)
        @default_adapter = name
      end

      def using(name, adapter = nil)
        default_adapter = @default_adapter
        register(name, adapter || @adapters[name])
        use(name)

        yield
      ensure
        @default_adapter = default_adapter
      end

      def adapter
        @adapters[@default_adapter]
      end

      def dump(set)
        adapter.dump(set)
      end

      def load(set)
        adapter.load(set)
      end

      module JSONNative
        extend self

        def dump(set) JSON.dump(set) end
        def load(set) JSON.load(set) end

        ROM::Redis::Serialization.register(:json_native, self)
      end
    end
  end
end
