// This is a vendor file that separate from main.js for sort out

/*
 * jQuery video background plugin
*/
;(function($, $win) {
	var BgVideoController = (function() {
		var videos = [];

		return {
			init: function() {
				$win.on('load.bgVideo resize.bgVideo orientationchange.bgVideo', this.resizeHandler.bind(this));
			},

			resizeHandler: function() {
				if (this.isInit) {
					$.each(videos, this.resizeVideo.bind(this));
				}
			},

			buildPoster: function($video, $holder) {
				$holder.css({
					'background-image': 'url(' + $video.attr('poster') + ')',
					'background-repeat':'no-repeat',
					'background-size':'cover'
				});
			},

			resizeVideo: function(i) {
				var item = videos[i];
				var styles = this.getDimensions({
					videoRatio: item.ratio,
					maskWidth: item.$holder.outerWidth(),
					maskHeight: item.$holder.outerHeight()
				});

				item.$video.css({
					width: styles.width,
					height: styles.height,
					marginTop: styles.top,
					marginLeft: styles.left
				});
			},

			getRatio: function($video) {
				return $video[0].videoWidth / $video[0].videoHeight ||
				$video.attr('width') / $video.attr('height') ||
				$video.width() / $video.height();
			},

			getDimensions: function(data) {
				var ratio = data.videoRatio,
					slideWidth = data.maskWidth,
					slideHeight = slideWidth / ratio;

				if (slideHeight < data.maskHeight) {
					slideHeight = data.maskHeight;
					slideWidth = slideHeight * ratio;
				}
				return {
					width: slideWidth,
					height: slideHeight,
					top: (data.maskHeight - slideHeight) / 2,
					left: (data.maskWidth - slideWidth) / 2
				};
			},

			add: function($video, options) {
				var $holder = options.videoHolder ? $video.closest(options.videoHolder) : $video.parent();
				var item = {
					$video: $video,
					$holder: $holder,
					options: options
				};

				if ($video.attr('poster')) {
					this.buildPoster($video, $holder);
				}

				if ($video[0].readyState) {
					this.onVideoReady(item);
					if ($video[0].paused) {
						$video[0].play();
					} else {
						$holder.addClass(options.activeClass);
					}
				} else {
					$video.one('loadedmetadata', function() {
						if ($video[0].paused) {
							$video[0].play();
						 } else {
							$holder.addClass(options.activeClass);
						 }
						 this.onVideoReady(item);
					}.bind(this));
				}

				$video.one('play', function() {
					$holder.addClass(options.activeClass);
					this.makeCallback.apply($.extend(true, {}, this, item), ['onPlay']);
				}.bind(this));


				this.makeCallback.apply($.extend(true, {}, this, item), ['onInit']);
				return this;
			},

			onVideoReady: function(item) {
				if (!this.isInit) {
					this.isInit = true;
					this.init();
				}
				videos.push($.extend(item, {
					ratio: this.getRatio(item.$video)
				}));
				this.resizeVideo(videos.length - 1);
			},

			destroy: function($video) {
				if (!$video) {
					videos = videos.filter(this.destroySingle);
				} else {
					videos = videos.filter(function(item) {
						var removeFlag = item.$video.is($video);

						removeFlag && this.destroySingle(item);

						return !removeFlag;
					}.bind(this));
				}

				if (!videos.length) {
					this.isInit = false;
					$win.off('.bgVideo');
				}
			},

			destroySingle: function(item) {
				item.$video.removeAttr('style').removeData('BackgroundVideo')[0].pause();
				item.$holder.removeClass(item.options.activeClass);
			},

			makeCallback: function(name) {
				if (typeof this.options[name] === 'function') {
					var args = Array.prototype.slice.call(arguments);
					args.shift();
					this.options[name].apply(this, args);
				}
			}
		};
	}());

	$.fn.backgroundVideo = function(opt) {
		var args = Array.prototype.slice.call(arguments);
		var method = args[0];
		var options = $.extend({
			activeClass: 'video-active',
			videoHolder: null
		}, opt);

		return this.each(function() {
			var $video = jQuery(this);
			var instance = $video.data('BackgroundVideo');

			if (typeof opt === 'object' || typeof opt === 'undefined') {
				$video.data('BackgroundVideo', BgVideoController.add($video, options));
			} else if (typeof method === 'string' && instance) {
				if (typeof instance[method] === 'function') {
					args.shift();
					instance[method].apply(instance, args);
				}
			}
		});
	};

	window.BgVideoController = BgVideoController;

	return BgVideoController;
}(jQuery, jQuery(window)));
