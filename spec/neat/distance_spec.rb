# frozen_string_literal: true

RSpec.describe Neat::Distance do
  subject(:distance) { described_class.new(genome_a, genome_b) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }
  let(:genome_a) { neat.create_genome }
  let(:genome_b) { neat.create_genome }

  describe '.call' do
    it 'creates a new instance and calls it' do
      distance = instance_double(described_class)

      allow(described_class).to receive(:new).with(genome_a, genome_b).and_return(distance)
      expect(distance).to receive(:call)

      described_class.call(genome_a, genome_b)
    end
  end

  describe '#call' do
    subject { distance.call }

    context 'with similar genomes' do
      it { is_expected.to be_positive }
    end

    context 'with identical genomes' do
      let(:distance) { described_class.new(genome_a, genome_a) }

      it { is_expected.to be_zero }
    end

    context 'with different genomes' do
      before { 5.times { Neat::Mutator.new(genome_b).add_node } }

      it { is_expected.to be_positive }
    end
  end

  describe '#matching_genes' do
    subject(:genes) { distance.matching_genes }

    it 'returns the matching genes between the genomes' do
      expect(genes.count).to eq(genome_a.connections.count)

      genes.each do |conn_a, conn_b|
        expect(conn_a).to eq(conn_b)
        expect(genome_a.connections).to include(have_attributes(id: conn_a.id, weight: conn_a.weight))
        expect(genome_b.connections).to include(have_attributes(id: conn_b.id, weight: conn_b.weight))
      end
    end
  end

  describe '#disjoint_genes' do
    subject(:genes) { distance.disjoint_genes }

    context 'with similar genomes' do
      it { is_expected.to be_empty }
    end

    context 'with different genomes' do
      before do
        Neat::Mutator.new(genome_a).add_node
        Neat::Mutator.new(genome_b).add_node
      end

      it 'returns the disjoint genes between the genomes' do
        expect(genes.count).to eq(2)

        max_id = genome_b.connections.map(&:id).max

        genes.each do |conn|
          expect(genome_a.connections).to include(have_attributes(id: conn.id, weight: conn.weight))
          expect(genome_b.connections).to_not include(conn)
          expect(conn.id).to be < max_id
        end
      end
    end
  end

  describe '#excess_genes' do
    subject(:genes) { distance.excess_genes }

    context 'with similar genomes' do
      it { is_expected.to be_empty }
    end

    context 'with different genomes' do
      before { Neat::Mutator.new(genome_a).add_node }

      it 'returns the disjoint genes between the genomes' do
        expect(genes.count).to eq(2)

        max_id = genome_b.connections.map(&:id).max

        genes.each do |conn|
          expect(genome_a.connections).to include(have_attributes(id: conn.id, weight: conn.weight))
          expect(genome_b.connections).to_not include(conn)
          expect(conn.id).to be > max_id
        end
      end
    end
  end
end
