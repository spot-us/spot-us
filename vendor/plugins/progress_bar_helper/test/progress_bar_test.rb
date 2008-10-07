require 'test/unit'
require 'rubygems'
require File.dirname(__FILE__) + '/../lib/progress_bar_helper'
require 'action_view/helpers/asset_tag_helper'

class ProgressBarTest < Test::Unit::TestCase
  
  include ProgressBarHelper
  include AssetTagHelper
  
  def test_progress_bar
    assert_equal progress_bar("test",0.5,true,true), "<span id=\"test7_progress_bar\" ><img alt=\"60.0%\" id=\"test7_percentImage\" src=\"/images/progress_bar/percentImage.png\" style=\"margin: 0pt; padding: 0pt; width: 120px; height: 12px;
                          background-position: -48.0px 50%;
                          background-image: url(/images/progress_bar/percentImage_back.png);\" title=\"80%\" /><span id=\"test7_percentText\">60.0%</span></span><script type=\"text/javascript\">
//<![CDATA[
$('test7_progress_bar').remove();
//]]>
</script><span id=\"test7\"></span><script type=\"text/javascript\">
//<![CDATA[

        Event.observe(window, 'load', function() {test7PB = new JS_BRAMUS.jsProgressBar(
                                    $('test7'),60.0,
                                    {
                                            showText	: true,
                                            animate	: true,
                                            width	: 120,
                                            height	: 12,
                                            boxImage	: '/images/progress_bar/percentImage.png?',
                                            barImage	: Array('/images/progress_bar/percentImage_back4.png?','/images/progress_bar/percentImage_back3.png?','/images/progress_bar/percentImage_back2.png?','/images/progress_bar/percentImage_back1.png?')
                                    }
                            );},
                      false);
//]]>
</script>"
  end
  
  def test_custom_progress_bar
    true
  end
  
end