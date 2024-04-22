RSpec.describe DslEvaluator::Printer do
  let(:printer) { described_class.new(error) }

  context "error info in message" do
    let(:error) do
      error = double(:error).as_null_object
      message = "/tmp/infra/config/app.rb:3: syntax error, unexpected end-of-input, expecting `end'"
      allow(error).to receive(:message).and_return(message)
      error
    end

    it "error_info" do
      expect(printer.error_info).to eq({
        path: "/tmp/infra/config/app.rb",
        line_number: "3"
      })
    end
  end
end
