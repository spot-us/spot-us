# This is a rails plugin of the famous jsProgressBarHandler of BRAMUS
# Is displays a progress bar filled at x%
# It can bez static or Javascript animated using Prototype functions.
# Working with Prototype 1.5 or later
# Author::    Thomas Gendulphe  (mailto:thomas.gendulphe@tgen.fr)
# Copyright::  Copyright (c) 2008
# License::   Distributes under creative commons Attribution-ShareAlike 2.5 license

module ProgressBarHelper

  # Render a static image percentage bar with default parameters
  # * name used as an id for the progress bar
  # * value decimal value to represent (i.e. value <= 1)
  # * display_percentage_text set to true to display the value in a text form
  def static_progress_bar(name, value, display_percentage_text = false)
    value = ((value*100.0).round.to_f)/100.0
    result =  '<span id="'+name+'_progress_bar" >'+
            image_tag('progress_bar/percentImage.png',
              :style => 'margin: 0pt; padding: 0pt; width: 180px; height: 20px;
                          background-position: '+(value*180-180).to_s+'px 50%;
                          background-image: url(/images/progress_bar/percentImage_back1.png);',
              :alt => (value*100).to_s+'%',
              :id => name+'_percentImage',
              :title => '80%')
     if display_percentage_text 
       result += '<span id="'+name+'_percentText">'+(value*100).to_s+'%'+'</span>'
     end
     result += '</span>'
  end


  def smaller_static_progress_bar(name, value, display_percentage_text = false)
    value = ((value*100.0).round.to_f)/100.0
    result =  '<span id="'+name+'_progress_bar" >'+
            image_tag('progress_bar/percentImage_old.png',
              :style => 'margin: 0pt; padding: 0pt; width: 120px; height: 12px;
                          background-position: '+(value*120-120).to_s+'px 50%;
                          background-image: url(/images/progress_bar/percentImage_back1_old.png);',
              :alt => (value*100).to_s+'%',
              :id => name+'_percentImage',
              :title => '80%')
     if display_percentage_text 
       result += '<span id="'+name+'_percentText">'+(value*100).to_s+'%'+'</span>'
     end
     result += '</span>'
  end
  
  # Render a customzed image percentage bar
  # * name : used as an id for the progress bar
  # * value : decimal value to represent (i.e. value <= 1)
  # * options : rendering options
  # 
  # Rendering options are:
  # * show_text : set to true to display percentage value in a text form
  # * animate : set to true to animate the image
  # * width : sets the width of the image (!must be the same as the actual box_image width
  # * height : sets the height of the image (!must be the same as the actual box_image height
  # * box_image : sets the container image
  # * bar_images : sets the progress bar images (must be an Array) 
  def custom_static_progress_bar(name, value, options = {})
    value = ((value*100.0).round.to_f)/100.0
    if options[:bar_images].nil? then
      bar_image = "'"+image_path('progress_bar/percentImage_back.png')+"'"
    else
      bar_image = "'"+image_path(options[:bar_images].first)+"'"
    end 
    result =  '<span id="'+name+'_progress_bar" >'+
            image_tag(options[:box_image]||'progress_bar/percentImage.png',
              :style => 'margin: 0pt; padding: 0pt; width: '+(options[:width]||120).to_s+'px; height: '+(options[:height]||12).to_s+'px;
                          background-position: '+(value*(options[:width]||120)-options[:width]||120).to_s+'px 50%;
                          background-image: url('+bar_image+');',
              :alt => (value*100).to_s+'%',
              :id => name+'_percentImage',
              :title => '80%')
     if !options[:show_text].nil? and options[:show_text]
       result += '<span id="'+name+'_percentText">'+(value*100).to_s+'%'+'</span>'
     end
     result += '</span>'
  end
  
  # Render an image percentage bar with all params set to default
  # * name : used as an id for the progress bar
  # * value : decimal value to represent (i.e. value <= 1)
  def dynamic_progress_bar(name, value)
    value = ((value*100.0).round.to_f)/100.0
    return '<span class="progressBar" id="'+name+'">'+(value*100).to_s+'</span>'
  end
 
  # Render a customized dynamic image percentage bar
  # * name : used as an id for the progress bar
  # * value : decimal value to represent (i.e. value <= 1)
  # * options : rendering options
  # 
  # Rendering options are:
  # * show_text : set to true to display percentage value in a text form
  # * animate : set to true to animate the image
  # * width : sets the width of the image (!must be the same as the actual box_image width
  # * height : sets the height of the image (!must be the same as the actual box_image height
  # * box_image : sets the container image
  # * bar_images : sets the progress bar images (must be an Array)  
  def custom_dynamic_progress_bar(name, value, options = {})
    value = ((value*100.0).round.to_f)/100.0
        # handle the case of several back images
    if options[:bar_images].nil? then
      bar_images = "'"+image_path('progress_bar/percentImage_back.png')+"'"
    else
      bar_images = "Array("+(options[:bar_images].map! { |x| "'"+image_path(x)+"'" }).join(",")+")"
    end
    # we set the progress bar
    result = '<span id="'+name+'"></span>'
    # we set the properties of the js observer
    result += javascript_tag("
        Event.observe(window, 'load', function() {"+
            name+"PB = new JS_BRAMUS.jsProgressBar(
                                    $('"+name+"'),"+
                                   (value*100).to_s+",
                                    {
                                            showText	: "+(options[:show_text]||false).to_s+",
                                            animate	: "+(options[:animate]||false).to_s+",
                                            width	: "+(options[:width]||120).to_s+",
                                            height	: "+(options[:height]||12).to_s+",
                                            boxImage	: '"+image_path(options[:box_image]||'progress_bar/percentImage.png')+"',
                                            barImage	: "+bar_images+"
                                    }
                            );},
                      false);")
  end
  
  # Render an animated image percentage bar with changing colors (only an image if javascript is deactivated)
  # * name : used as an id for the progress bar
  # * value : decimal value to represent (i.e. value <= 1)
  # * display_percentage_text : set to true to display the value in a text form
  # * multicolor : set to true for a progress bar changing its color depending on percecntage
  def progress_bar(name,value, display_percentage_text = false, multicolor = false)
    value = ((value*100.0).round.to_f)/100.0
    result = static_progress_bar(name,value, display_percentage_text)
    result += javascript_tag("$('"+name+"_progress_bar').remove();")
    if multicolor then
      result += custom_dynamic_progress_bar(name,value,{:show_text => display_percentage_text, :animate => true, :bar_images => ['progress_bar/percentImage_back4.png','progress_bar/percentImage_back3.png','progress_bar/percentImage_back2.png','progress_bar/percentImage_back1.png']})
    else
      result += custom_dynamic_progress_bar(name, value, {:show_text => display_percentage_text, :animate => true})
    end
    return result
  end

  
  # Render a customized image percentage bar (javascript fallback included)
  # * name : used as an id for the progress bar
  # * value : decimal value to represent (i.e. value <= 1)
  # * options : rendering options
  # 
  # Rendering options are:
  # * show_text : set to true to display percentage value in a text form
  # * animate : set to true to animate the image
  # * width : sets the width of the image (!must be the same as the actual box_image width
  # * height : sets the height of the image (!must be the same as the actual box_image height
  # * box_image : sets the container image
  # * bar_images : sets the progress bar images (must be an Array)  
  def custom_progress_bar(name,value,options = {})
    value = ((value*100.0).round.to_f)/100.0
    result = custom_static_progress_bar(name,value, options)
    result += javascript_tag("$('"+name+"_progress_bar').remove();")
    result += custom_dynamic_progress_bar(name, value, options)
  end
  
  # Adds necessary js file tags
  # Place this in the header of your layout (near othe javascript_include_tag)
  def progress_bar_includes
    return '<!-- jsProgressBarHandler core -->'+javascript_include_tag("progress_bar/jsProgressBarHandler.js")
  end
  
end
  