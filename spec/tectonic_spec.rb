require "open3"
require "origami"
include Origami
RSpec.describe Tectonic do
  it "has a version number" do
    expect(Tectonic::VERSION).not_to be nil
  end

  it "PDF generation" do
    latex = <<-EOS
      \\documentclass{article}
      \\begin{document}
      Hello, world!
      \\end{document}
    EOS
    # https://github.com/tectonic-typesetting/tectonic/issues/284
    # To be deterministic behavior, 
    ENV["SOURCE_DATE_EPOCH"] = "1456304492"
    # a.pdf
    Open3.capture2("tectonic -", stdin_data: latex)
    FileUtils.mv("texput.pdf", "a.pdf")
    # b.pdf
    bin = Tectonic.latex_to_pdf(latex).pack("C*")
    File.binwrite("b.pdf", bin)
    # Normalize
    # Because R/ID in PDF is generated by pathname
    pdf = PDF.read("a.pdf")
    pdf.trailer.ID=["0"*32,"0"*32]
    pdf.save("a.pdf")
    pdf = PDF.read("b.pdf")
    pdf.trailer.ID=["0"*32,"0"*32]
    pdf.save("b.pdf")
    # Compare
    cmp = FileUtils.cmp("a.pdf", "b.pdf")
    expect(cmp).to eq true
    # Clean up
    FileUtils.rm_f(["a.pdf", "b.pdf"])
  end
end
