# frozen_string_literal: true

RSpec.describe Neat::Crossover do
  subject(:crossover) { described_class.new(genome_a, genome_b) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }
  let(:genome_a) { neat.create_genome }
  let(:genome_b) { neat.create_genome }

  let(:distance) { Neat::Distance.new(genome_a, genome_b) }

  describe '#crossover' do
    subject(:child) { crossover.crossover }

    before do
      Neat::Mutator.new(genome_a).add_node
      Neat::Mutator.new(genome_b).add_node
      Neat::Mutator.new(genome_a).add_node

      # Disables a gene
      genome_b.connections.first.enabled = false
    end

    it 'returns a new genome' do
      expect(child).to be_a(Neat::Genome)
      expect(child.nodes.count).to eq(genome_a.nodes.count)
      expect(child.connections.count).to eq(genome_a.connections.count)
      expect(child).to_not eq(genome_a)
      expect(child).to_not eq(genome_b)
    end

    it 'includes both parents matching genes' do
      distance.matching_genes.each do |conn_a, conn_b|
        conn = child.connections.find { _1.id == conn_a.id }
        expect([conn_a.weight, conn_b.weight]).to include(conn.weight)
      end
    end

    it 'includes parent A disjoint genes' do
      distance.disjoint_a_genes.each do |conn|
        expect(child.connections).to include(have_attributes(from: conn.from, to: conn.to, weight: conn.weight))
      end
    end

    it 'includes parent A excess genes' do
      distance.excess_a_genes.each do |conn|
        expect(child.connections).to include(have_attributes(from: conn.from, to: conn.to, weight: conn.weight))
      end
    end

    context 'when crossover_inherit_disabled_gene_probability is 100%' do
      before { allow(Neat.config).to receive(:crossover_inherit_disabled_gene_probability).and_return(1.0) }

      it 'inherits the disabled gene' do
        expect(child.connections.first).to be_disabled
      end
    end

    context 'when crossover_inherit_disabled_gene_probability is 0%' do
      before { allow(Neat.config).to receive(:crossover_inherit_disabled_gene_probability).and_return(0) }

      it 'does not inherit the disabled gene' do
        expect(child.connections.first).to be_enabled
      end
    end
  end
end
