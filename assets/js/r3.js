function initMorphingButtons(){
     //   simulate morphing buttons for demo purpose
    
    $('#successBtn').click(function(){
       var $button = $(this);
                 
        // simulate a Success Ajax call for 2 seconds         
        setTimeout(function(){
            $button.morphingButton({
                action: 'setState',
                icon: 'fa-check',
                state: 'success'
            });        
        }, 2000);
    });
    
     $('#errorBtn').click(function(){
        var $button = $(this);
        
        // simulate a Error Ajax call for 2 seconds          
        setTimeout(function(){
            $button.morphingButton({
                action: 'setState',
                icon: 'fa-times',
                state: 'error'
            });        
        }, 2000);
    });
    
    $('#starBtn').click(function(){
        var $button = $(this);
    
        $button.morphingButton({
            action: 'setState',
            icon: 'fa-star',
            state: 'warning'
        });        
     
    });
    
    $('#thumbBtn').click(function(){
        var $button = $(this);
        setTimeout(function(){
            $button.morphingButton({
                action: 'setState',
                icon: 'fa-thumbs-up',
                state: 'info'
            });        
        }, 2000);
    });
}

/*function initDemoChartist(){
    var dataPerformance = {
      labels: ['9pm', '2am', '8am', '2pm', '8pm', '11pm', '4am'],
      series: [
        [1, 6, 8, 7, 4, 7, 8, 12, 16, 17, 14, 13]
      ]
    };
    
    var optionsPerformance = {
      showPoint: false,
      lineSmooth: true,
      axisX: {
        showGrid: false,
        showLabel: true
      },
      axisY: {
        offset: 40,
      },
      low: 0,
      high: 16
    };

    Chartist.Line('#chartPerformance', dataPerformance, optionsPerformance);
    
    var dataStock = {
      labels: ['\'07','\'08','\'09', '\'10', '\'11', '\'12', '\'13', '\'14', '\'15'],
      series: [
        [22.20, 34.90, 42.28, 51.93, 62.21, 80.23, 62.21, 78.83, 82.12, 102.50, 107.23]
      ]
    };
    
    var optionsStock = {
      lineSmooth: false,
      axisY: {
        offset: 40,
        labelInterpolationFnc: function(value) {
            return '$' + value;
          }

      },
      low: 10,
      high: 110,
       classNames: {
          point: 'ct-point ct-green',
          line: 'ct-line ct-green'
      }
    };
     
    var $chart = $('#chartStock');
    
    Chartist.Line('#chartStock', dataStock, optionsStock);     
    
    var dataSales = {
      labels: ['\'06','\'07','\'08','\'09', '\'10', '\'11', '\'12', '\'13', '\'14','\'15'],
      series: [
        [287, 385, 490, 492, 554, 586, 698, 695, 752, 788, 846, 944],
        [67, 152, 143, 240, 287, 335, 435, 437, 539, 542, 544, 647],
        [23, 113, 67, 108, 190, 239, 307, 308, 439, 410, 410, 509]
      ]
    };
    
    var optionsSales = {
      lineSmooth: false,
      axisY: {
        offset: 40
      },
      low: 0,
      high: 1000     
    };

    Chartist.Line('#chartSales', dataSales, optionsSales);

    var data = {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      series: [
        [542, 443, 320, 780, 553, 453, 326, 434, 568, 610, 756, 895],
        [412, 243, 280, 580, 453, 353, 300, 364, 368, 410, 636, 695]
      ]
    };
    
    var options = {
      seriesBarDistance: 10,
       axisX: {
            showGrid: false
        }
    };
    
    var responsiveOptions = [
      ['screen and (max-width: 640px)', {
        seriesBarDistance: 5,
        axisX: {
          labelInterpolationFnc: function (value) {
            return value[0];
          }
        }
      }]
    ];
    
    Chartist.Bar('#chartActivity', data, options, responsiveOptions);

    var dataViews = {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      series: [
        [542, 443, 320, 780, 553, 453, 326, 434, 568, 610, 756, 895]
      ]
    };
    
    var optionsViews = {
      seriesBarDistance: 10,
      classNames: {
        bar: 'ct-bar ct-azure'
      },
      axisX: {
        showGrid: false
      }
    };
    
    var responsiveOptionsViews = [
      ['screen and (max-width: 640px)', {
        seriesBarDistance: 5,
        axisX: {
          labelInterpolationFnc: function (value) {
            return value[0];
          }
        }
      }]
    ];
    
    Chartist.Bar('#chartViews', dataViews, optionsViews, responsiveOptionsViews);

    var dataPreferences = {
        series: [
            [25, 30, 20, 25]
        ]
    };
    
    var optionsPreferences = {
        donut: true,
        donutWidth: 40,
        startAngle: 0,
        total: 100,
        showLabel: false,
        axisX: {
            showGrid: false
        }
    };

    //Chartist.Pie('#chartPreferences', dataPreferences, optionsPreferences);
    
    Chartist.Pie('#chartPreferences', {
      labels: ['46%','28%','15%','11%'],
      series: [46, 28, 15, 11]
    });

}
*/
/*
function initGoogleMaps(){
    var myLatlng = new google.maps.LatLng(44.433530, 26.093928);
    var mapOptions = {
      zoom: 14,
      center: myLatlng,
      scrollwheel: false, //we disable de scroll over the map, it is a really annoing when you scroll through page
    }
    var map = new google.maps.Map(document.getElementById("map"), mapOptions);
    
    var marker = new google.maps.Marker({
        position: myLatlng,
        title:"Hello World!"
    });
    
    // To add the marker to the map, call setMap();
    marker.setMap(map);
}*/

function checkImgSize() {
	if ($(window).width() > 767){
		var allImgSlider = $('#wowslider-container1 .ws_images li img').toArray();
		//.ws_effect canvas
		for (var i = 0; i < $(allImgSlider).size(); i++){
			$(allImgSlider[i]).width('100%');
			$(allImgSlider[i]).height('auto');
			if ($(allImgSlider[i]).height() > $(allImgSlider[i]).closest('.ws_images').height()){
				$(allImgSlider[i]).height($(window).height());
				$(allImgSlider[i]).width('auto');
			}
		};
		$('div#wowslider-container1 .ws_images').width($(window).width() - 220 - 100);
	}
}

$(document).ready(function(){
		if ($('.carousel.slide').height() != null){
			$('.carousel .item').height($(window).height());
		}
		
		$('.info-project.info-closed.related2').height($(window).height());
	window.onload = function() {
		if ($('#wowslider-container1').height() != null){
		$('.ws_images').height($(window).height());
		$('div#wowslider-container1').width($(window).width() - 220);
		$('.info-project.info-closed.related2').height($(window).height());
		checkImgSize();
		$('#wowslider-container1 .ws_images .main_slider')[0].onmousedown = function(e) {
			e.target.onmousemove = function(e1) {
				e1.target.onmouseup= function(e2) {
					if(e.pageX < e1.pageX){
						var old_num = $('span#curr_num').text();
						//if (old_num == $('span#curr_all').text()){
						if (old_num == '1'){
							$('span#curr_num').text($('span#curr_all').text());
						} else {
							$('span#curr_num').text(old_num-1);
						}
					} else {
						var old_num = $('span#curr_num').text();
						if (old_num == $('span#curr_all').text()){
							$('span#curr_num').text(1);
						} else {
							$('span#curr_num').text((Number(old_num)+1));
						}
					}
				};
			};
		};
		
		var deltaMoove = 0;
		$('#wowslider-container1 .ws_images .main_slider').on('touchstart', function(event) {
			
			var start_touch = event.originalEvent.touches[0].pageX;
			$('#wowslider-container1 .ws_images .main_slider').on('touchmove', function(event) {
					if(start_touch < event.originalEvent.touches[0].pageX){
						deltaMoove = 0;
					}else {
						deltaMoove = 1;
					}
			});
			
				
		});
		$('#wowslider-container1 .ws_images .main_slider').on('touchend', function(e2) {
					if (deltaMoove==0){
					console.log('sd')
						var old_num = $('span#curr_num').text();
						if (old_num == '1'){
							$('span#curr_num').text($('span#curr_all').text());
						} else {
							$('span#curr_num').text((Number(old_num)-1));
						}
					} else {
						var old_num = $('span#curr_num').text();
						if (old_num == $('span#curr_all').text()){
							$('span#curr_num').text(1);
						} else {
							$('span#curr_num').text((Number(old_num)+1));
						}
					}
				});
				}
		$('.carousel .item').height($(window).height());
		$('div#wowslider-container1').height($(window).height());
			//
		var h1 = $('a.homeProjects')[0].clientHeight;
		var h2 = $('.socialNetwork-projects')[0].clientHeight;
		var h3 = $('.related-projects')[0].clientHeight;
		var wH = $(window).height();
		if ($('.body-gallery').height() != null){
			var h4 = $('.navbar')[0].clientHeight;
			$('.body-gallery .content-descricao').height(wH - h1 - h2 - h3 - 30 - h4);
		} else {
			$('.content-descricao').height(wH - h1 - h2 - h3 - 30);
		}
		//
		$('.carousel .item img').css('max-width', 'none');
		$('.carousel .carousel-inner').height($(window).height());
		$('.gallery_wrapp').height($(window).height());
		$('#nav_wrap').height($(window).height());
		$('.ws_images').height($(window).height());
		//$('.ws_controls').width($(window).width() - 100);
		$('div#wowslider-container1').width($(window).width() - 220);
		$('.gallery_wrapp').width($(window).width() - 220);
		//details
		$('.details').click(function () {
			$(".info-project.info-closed.related2").slideToggle("medium");
			$("body").toggleClass("open_info");
		});
		/*$('.closed').click(function () {
			$(".info-project.info-closed.related2").slideDown("medium");
			$("body").addClass("open_info");
		});*/
		var scrolled = 0;
		$('.ws_thumbs').scroll(function() {
			scrolled = $('.ws_thumbs')[0].pageYOffset || $('.ws_thumbs')[0].scrollTop;
		});
		$("#scroll_top").on('click',function(e){
			e.preventDefault();
			var whatScroll = $('.ws_thumbs').height()/3;
			if (scrolled > whatScroll){
				$('.ws_thumbs').animate({
					scrollTop: (whatScroll/2)
				}, 500);
			} else{
				$('.ws_thumbs').animate({
					scrollTop: (0)
				}, 500);
			}
		});
		$("#scroll_bottom").on('click',function(e){
			e.preventDefault();
			var whatScroll = $('.ws_thumbs').height()/3;
			if (scrolled < whatScroll){
				$('.ws_thumbs').animate({
					scrollTop: (scrolled + whatScroll/2)
				}, 500);
			} else{
				$('.ws_thumbs').animate({
					scrollTop: (whatScroll*3)
				}, 500);
			}
		});
		checkImgSize();
	};
});
$(window).resize(function() {
	if ($('.carousel.slide').height() != null){
		$('.carousel .item').height($(window).height());
	}
	$('.carousel .carousel-inner').height($(window).height());
	$('.carousel .item').height($(window).height());
	$('div#wowslider-container1').height($(window).height());
	$('#nav_wrap').height($(window).height());
	$('.ws_images').height($(window).height());
	$('.info-project.info-closed.related2').height($(window).height());
	//$('.ws_controls').width($(window).width() - 100);
	$('div#wowslider-container1').width($(window).width() - 220);
	$('.gallery_wrapp').width($(window).width() - 220);
	$('.gallery_wrapp').height($(window).height());
	checkImgSize();
});
