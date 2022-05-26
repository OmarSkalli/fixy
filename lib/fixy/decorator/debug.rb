module Fixy
  module Decorator
    class Debug
      class << self
        def document(document)
          '<html>
            <head>
              <script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
              <script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
              <style>
                body  { margin: 0; padding: 0; background-color: #EFEFEF; }
                pre   { margin: 0; }
                .even { background-color: #ABABAB; }
                .odd  { background-color: #CDCDCD; }
                b     { font-size: 15px; }
                .line { width: 50px; text-align: right; margin-right: 10px; color: #7f8284; display: inline-block; background-color: #272822; padding-right: 5px;}
                span:hover { background-color: yellow; }
                span.line:hover { background-color: #3e3d32; }
                .tooltip        { min-width: 250px; position: absolute; z-index: 1030; display: block; font-size: 12px; line-height: 1.4; visibility: visible; filter: alpha(opacity=0); opacity: 0; }
                .tooltip.in     { filter: alpha(opacity=90); opacity: .9; }
                .tooltip.bottom { padding: 5px 0; margin-top: 3px; }
                .tooltip-inner  {  max-width: 200px; padding: 3px 8px;  color: #fff; text-align: center;  text-decoration: none; background-color: #000; border-radius: 4px; }
                .tooltip-arrow  { position: absolute; width: 0; height: 0; border-color: transparent; border-style: solid; }
                .tooltip.bottom .tooltip-arrow { top: 0; left: 50%; margin-left: -5px; border-width: 0 5px 5px; border-bottom-color: #000; }
              </style>
              <script type="text/javascript">
                $(document).ready(function() {
                    $("div").each(function(i, div) {
                        $div = $(div);
                        $spans = $div.find("span");
                        $spans.each(function(j, span) {
                            element = $(span);
                            method = element.data("method");
                            size = element.data("size");
                            format = element.data("format");
                            column = element.data("column");
                            line = i + 1;

                            $(element).tooltip({
                                title: ("<b>" + method + "</b><br/>Line: " + line + "<br/>Column: " + column + "<br/>Length: " + size + "<br/>Formatter: " + format),
                                placement: "bottom",
                                container: "body",
                                html: true
                            });
                        });
                        $div.find("pre").prepend("<span class=\'line\'>" + (i + 1) + "</span>");
                    });
                });
              </script>
            </head>
            <body>' + document + '</body>
          </html>'
        end

        def field(value, record_number, position, method, length, type)
          "<span class='#{(record_number.even?? 'even' : 'odd')}' data-column='#{position}' data-method='#{method}' data-size='#{length}' data-format='#{type}'>#{value}</span>"
        end

        def record(record)
          "<div><pre>#{record}</pre></div>"
        end
      end
    end
  end
end
