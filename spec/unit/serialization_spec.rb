require 'spec_helper'

describe ROM::Redis::Serialization do
  module AdapterStub
    extend self

    @registered_dumps = []
    @registered_loads = []

    def registered_dumps; @registered_dumps; end
    def registered_loads; @registered_loads; end

    def load(set)
      @registered_loads << set
      :load
    end

    def dump(set)
      @registered_dumps << set
      :dump
    end

    ROM::Redis::Serialization.register(:adapter_stub, self)
  end

  describe "adapter registration" do
    it "registers the adapter correctly" do
      described_class.using(:adapter_stub) do
        expect(described_class.adapter).to eq AdapterStub
      end
    end
  end

  describe "adapter usage" do
    it "loads data" do
      described_class.using(:adapter_stub) do
        expect { described_class.load('foobar') }
          .to change { AdapterStub.registered_loads }
          .from([]).to(['foobar'])
      end
    end

    it "dumps data" do
      described_class.using(:adapter_stub) do
        expect { described_class.dump('foobar') }
          .to change { AdapterStub.registered_dumps }
          .from([]).to(['foobar'])
      end
    end
  end

  if defined? JSON
    describe ROM::Redis::Serialization::JSONNative do
      describe ".dump" do
        it "dumps the object using JSON" do
          expect(described_class.dump(foo: "bar")).to eq %({"foo":"bar"})
        end
      end

      describe ".load" do
        it "loads the object using JSON" do
          expect(described_class.load(%({"foo":"bar"}))).to eq("foo" => "bar")
        end
      end
    end
  end
end
