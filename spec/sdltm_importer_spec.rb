require 'spec_helper'

describe SdltmImporter do
  it 'has a version number' do
    expect(SdltmImporter::VERSION).not_to be nil
  end

  describe '#stats' do
    it 'reports the stats of a .sdltm file' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.stats).to eq({:tu_count=>537, :seg_count=>1074, :language_pairs=>[["fr-FR", "en-US"]]})
    end

    it 'reports the stats of a .sdltm file 2' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample_2.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.stats).to eq({:tu_count=>102, :seg_count=>204, :language_pairs=>[["en-US", "de-DE"]]})
    end
  end

  describe '#import' do
    it 'imports a .sdltm file 1' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[0].length).to eq(537)
    end

    it 'imports a .sdltm file 2' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[1].length).to eq(1074)
    end

    it 'imports a .sdltm file 3' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[1][-1][4]).to eq("Your website's URL")
    end

    it 'imports a .sdltm file 4' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample_2.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[0].length).to eq(102)
    end

    it 'imports a .sdltm file 5' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample_2.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[1].length).to eq(204)
    end

    it 'imports a .sdltm file 6' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample_2.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[0][-1][0]).to eq(sdltm.import[1][-1][0])
    end

    it 'imports a .sdltm file 6' do
      file_path = File.expand_path('../sdltm_importer/spec/sample_test_files/sample_2.sdltm')
      sdltm = SdltmImporter::Sdltm.new(file_path: file_path)
      expect(sdltm.import[0][1][0]).to eq(sdltm.import[1][3][0])
    end
  end
end
