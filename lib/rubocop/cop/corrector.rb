# encoding: utf-8

module RuboCop
  module Cop
=begin
    This class takes a source buffer and rewrite its source
    based on the different correction rules supplied.

    Important!
    The nodes modified by the corrections should be part of the
    AST of the source_buffer.
=end    
    class Corrector
=begin
      @param source_buffer [Parser::Source::Buffer]
      @param corrections [Array(#call)]
        Array of Objects that respond to #call. They will receive the
        corrector itself and should use its method to modify the source.
  
      @example
  
      class AndOrCorrector
        def initialize(node)
          @node = node
        end
      
        def call(corrector)
          replacement = (@node.type == :and ? '&&' : '||')
          corrector.replace(@node.loc.operator, replacement)
        end
      end

      corrections = [AndOrCorrector.new(node)]
      corrector = Corrector.new(source_buffer, corrections)
=end
      def initialize(source_buffer, corrections)
        @source_buffer = source_buffer
        @corrections = corrections
        @source_rewriter = Parser::Source::Rewriter.new(source_buffer)
      end
=begin
      Does the actual rewrite and returns string corresponding to
      the rewritten source.

      @return [String]
      TODO: Handle conflict exceptions raised from the Source::Rewriter
=end
      def rewrite
        @corrections.each { |correction|  correction.call self}

        @source_rewriter.process
      end
=begin
      Removes the source range.

      @param [Parser::Source::Range] range
=end
      def remove(range); @source_rewriter.remove range; end
=begin
      Inserts new code before the given source range.

      @param [Parser::Source::Range] range
      @param [String] content
=end
      def insert_before(range, content); @source_rewriter.insert_before range, content; end
=begin
      Inserts new code after the given source range.

      @param [Parser::Source::Range] range
      @param [String] content
=end
      def insert_after(range, content)
        @source_rewriter.insert_after(range, content)
      end
=begin
      Replaces the code of the source range `range` with `content`.

      @param [Parser::Source::Range] range
      @param [String] content
=end
      def replace(range, content); @source_rewriter.replace range, content; end
    end
  end
end
