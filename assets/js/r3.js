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



	$.fn.ogSlider = function() {
		$(this).height( $(window).height() * 0.7 );
		$('.four_blocks').height( $(window).height() * 0.3 );
		$('.four_blocks .col-sm-3').height( $(window).height() * 0.3 );
		$(window).resize(function() {
			$(this).height( $(window).height() * 0.7 );
			$('.four_blocks').height( $(window).height() * 0.3 );
			$('.four_blocks .col-sm-3').height( $(window).height() * 0.3 );
		});
		
		var eachSlide = $(this).find('.og-slide').toArray();
		$(eachSlide[0]).addClass('og-active-slide');
		for (var i = 0; i < $(eachSlide).size(); i++){
			eachSlide[i].numOfSlide = i;
		};
		
		function nextSlide() {
			var activeSlide = $('.og-active-slide')[0];
			if ( activeSlide.numOfSlide == $(eachSlide).size() - 1 ){
				$(activeSlide).removeClass('og-active-slide');
				$(eachSlide[0]).addClass('og-active-slide');
				$('.og-active-slide').siblings().removeClass('og-active-slide');
			} else {
				$(activeSlide).removeClass('og-active-slide');
				$(activeSlide).next().addClass('og-active-slide');
				$('.og-active-slide').siblings().removeClass('og-active-slide');
			}
		};
		
		function prevSlide() {
			var activeSlide = $('.og-active-slide')[0];
			if ( activeSlide.numOfSlide == 0 ){
				$(activeSlide).removeClass('og-active-slide');
				$(eachSlide[ $(eachSlide).size() - 1 ]).addClass('og-active-slide');
				$('.og-active-slide').siblings().removeClass('og-active-slide');
			} else {
				$(activeSlide).removeClass('og-active-slide');
				$(activeSlide).prev().addClass('og-active-slide');
				$('.og-active-slide').siblings().removeClass('og-active-slide');
			}
		};
		
		$('#og-next').click(function () {
			nextSlide();
		});
		
		$('#og-prev').click(function () {
			prevSlide();
		});
		
		$(this).mouseenter(function(){
			$(this).addClass('hovering')
		}).mouseleave(function(){
			$(this).removeClass('hovering')
		});
		
		setInterval(function () {
			if ( !$('.hovering').hasClass('hovering')){
				nextSlide();
			}
		}, 3000);
		
		
	};
	
	

$(document).ready(function(){
		if ($('.og-slider_new').height() != null){
			$('.og-slider_new').ogSlider();
		}
		
		if ($('.carousel.slide').height() != null){
			$('.carousel .item').height($(window).height());
		}
		
		$('.info-project.info-closed.related2').height($(window).height());
	window.onload = function() {
		if ($('body').hasClass('body-gallery') || $('body').hasClass('body-slider') ){
			
			
			
			$('.carousel .item img').css('max-width', 'none');
			$('.carousel .carousel-inner').height($(window).height());
			$('.gallery_wrapp').height($(window).height() - 90);
			$('#nav_wrap').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			$('.ws_images').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			//$('.ws_controls').width($(window).width() - 100);
			$('div#wowslider-container1').width( $(window).width() - 220 );
			$('.gallery_wrapp').width( $(window).width() - 220 );
			$('div#wowslider-container1').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			$('#nav_wrap').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			$('.ws_images').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			//details
			$('.details').click(function () {
				$(".info-project.info-closed.related2").slideToggle("medium");
				$("body").toggleClass("open_info");
			});
			$('.preloader').removeClass('hidden');
			
			
			
			
			function checkImgSizeSl() {
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
				} else {
					var allImgSlider = $('#wowslider-container1 .ws_images li img').toArray();
					//.ws_effect canvas
					for (var i = 0; i < $(allImgSlider).size(); i++){
						$(allImgSlider[i]).width('100%');
						$(allImgSlider[i]).height('auto');
						var looking_height = $(window).height() - 147 + 16;
						if ($(allImgSlider[i]).height() > looking_height  ){
							$(allImgSlider[i]).height(looking_height);
							$(allImgSlider[i]).width('auto');
						}
					};
				}
			};
			
			checkImgSizeSl();
		}
		if ($('#wowslider-container1').height() != null){
		$('div#wowslider-container1').width($(window).width() - 220);
		$('.info-project.info-closed.related2').height($(window).height());
		$('div#wowslider-container1').height($(window).height() - 60 );
		//checkImgSize();
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
		/*$('.carousel .item').height($(window).height());
		$('div#wowslider-container1').height( $(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
			//
		$('.carousel .item img').css('max-width', 'none');
		$('.carousel .carousel-inner').height($(window).height());
		$('.gallery_wrapp').height($(window).height() - 120);
		$('#nav_wrap').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
		$('.ws_images').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
		//$('.ws_controls').width($(window).width() - 100);
		$('div#wowslider-container1').width( $(window).width() - 220 );
		$('.gallery_wrapp').width( $(window).width() - 220 );
		//details
		$('.details').click(function () {
			$(".info-project.info-closed.related2").slideToggle("medium");
			$("body").toggleClass("open_info");
		});*/
		try{
			var h1 = $('a.homeProjects')[0].clientHeight;
			var h3 = $('.related-projects')[0].clientHeight;
			var wH = $(window).height();
			if ($('.body-gallery').height() != null){
				var h4 = $('.navbar')[0].clientHeight;
				$('.body-gallery .content-descricao').height(wH - h1 - h3 - 30 - h4);
			} else {
				$('.content-descricao').height(wH - h1 - h3 - 30);
			}
		} catch(error){
			
		}
		//
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
	$('div#wowslider-container1').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
	$('#nav_wrap').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
	$('.ws_images').height($(window).height() - $('body.body-slider.body-gallery .navbar-default').height() );
	$('.info-project.info-closed.related2').height($(window).height());
	//$('.ws_controls').width($(window).width() - 100);
	$('div#wowslider-container1').width($(window).width() - 220);
	$('.gallery_wrapp').width($(window).width() - 220);
	$('.gallery_wrapp').height($(window).height() - 9);
	checkImgSize();
});
