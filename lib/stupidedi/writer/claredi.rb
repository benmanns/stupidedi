# frozen_string_literal: true
module Stupidedi
  using Refinements

  module Writer
    class Claredi
      def initialize(node)
        @node = node
      end

      # @return [String]
      def write(out = StringIO.new)
        out << "<html><head>\n#{style}</head>\n<body>\n"
        build(@node, out)
        out << "</body></html>"

        out.string
      end

    private

      # @return [String]
      def style
        <<-CSS
        <style>
          body { font-size: 0.75em; }

          .interchange, .functionalgr, .table, .loop > .label {
            font-weight: bold;
            font-family: Georgia;
          }

          .interchange, .functionalgr, .transaction {
            margin-left:   1em;
            margin-top:    1em;
            margin-bottom: 1em;
          }

          .transaction > .label {
            font-weight: bold;
            font-size: 1.5em;
          }

          .table, .loop {
            margin-top:    0.5em;
            margin-bottom: 0.5em;
            margin-right:  0.5em;
          }

          .table { margin-left: 1em; margin-bottom: 2em; }
          .table > .label {
            font-size:     1.25em;
            border-bottom: 3px solid black;
            margin-top:    1em;
            margin-bottom: 0.5em;
          }

          .loop { border: 1px solid grey; border-left: 0; }
          .loop > .label {
            padding:          3px;
            background-color: #ddd;
          }

          .segment {
            display: inline;
            margin-top:  0.25em;
            background-color: #fff;
            font-weight: normal;
          }

          .segment > .label {
            font-weight: normal;
            font-family: Consolas, Monospace, monospace;
          }
        </style>
        CSS
      end

      # @return [void]
      def build(node, out = StringIO.new)
        if node.element?
          if node.composite?
            out << "*"
            tmp = StringIO.new
            node.children.each{|e| build(e, tmp) }
            out << tmp.string.gsub(/:*$/, "")
          elsif node.component?
            out << "#{node}:"
          elsif node.repeated?
            out << "^"
            node.children.each{|e| build(e, out) }
          else
            out << "*#{node}"
          end

        elsif node.segment?
          out << %q(<div class="segment"><div class="label" title="#{node.definition.name}">)
          out << "% 3s" % node.definition.id
          # out << ": #{node.definition.name}</div></div>\n"
          tmp  = StringIO.new
          node.children.each{|e| build(e, tmp) }
          tmp = tmp.string.gsub(/\**$/, "")
          out << "#{tmp}~</div></div>\n"

        elsif node.loop?
          m = /^\w+ (.+)$/.match(node.definition.id)
          name = m.captures
          name = name.split(/\s+/).map(&:capitalize).join(" ")

          out << %q(<div class="loop"><div class="label">#{name} (#{id})</div>\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"

        elsif node.table?
          out << %q(<div class="table"><div class="label">#{node.definition.id}</div>\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"

        elsif node.transaction_set?
          out << %q(<div class="transaction"><div class="label">Transaction Set #{node.definition.id}</div>\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"

        elsif node.functional_group?
          out << %q(<div class="functionalgr"><div class="label">Functional Group #{node.definition.id}</div>\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"

        elsif node.interchange?
          out << %q(<div class="interchange"><div class="label">Interchange #{node.definition.id}</div>\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"

        elsif node.transmission?
          out << %q(<div class="transmission">\n)
          node.children.each{|c| build(c, out) }
          out << "</div>\n"
        end
      end
    end
  end
end
