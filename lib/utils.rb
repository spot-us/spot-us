module Utils
  def strip_html(text)
     text.gsub(/<\/?[^>]*>/, "")
  end

  def html_cleanup(text)
    Sanitize.clean(text, :elements => ['a','p','br','div','img','object','embed','param','strong','b','i','li','ol','blockquote',
                  'cite','code','dd','dl','dt','em','pre','q','small','strike','sub','sup','h1','h2','h3','h4','h5','h6'],
         :attributes => {'a' => ['href','target'],
                         'img' => ['src','width','height','style'],
                         'param' => ['name','value'],
                         'object' => ['width','height','type','data'],
                         'embed' => ['src','allowfullscreen','wmode','type','allowscriptaccess','width','height']},
         :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}},
         :allow_comments => false, :remove_contents => true)
  end

end