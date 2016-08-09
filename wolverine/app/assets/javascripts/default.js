$(function(){

	$(document).on('keypress', 'input:not(.allow_submit)', function(event) {
		return event.which !== 13;
	});

	$('.block-link').click(function(){
		location.href = $(this).find('a').attr('href');
	});

	$('.is-num').each(function(){
		$(this).blur(function(){
			$(this).removeClass('ipt-error');
			$(this).parent().find('.txt-error').remove();
			$(this).parents('form').find('button:submit').attr('disabled', false);
			var Num = $(this).val();
			if ( Num != '' && !Num.match(/^[0-9]+$/) ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">半角数字で入力してください</p>');
				$(this).parents('form').find('button:submit').attr('disabled', true);
			}
		});
	});

	$('#submit-create').on('click', function(){

		errorReset();
		function errorReset() {
			$('select').removeClass('ipt-error');
			$('.txt-error').remove();
		}

		$('.s-required').each(function(){
			if ($(this).val() == '0') {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">入力してください</p>');
			}
		});

		if ($('.ipt-error').size() != '0') {
			return false;
		} else {
			errorReset();
			var Category = $('#entry-category').find(':selected').data('action');
			$('#entry-form').attr('action', Category);
		}

	});

	$('.add-btn').click(function(){
		var Type = $(this).data('type');
		if (Type == 'plan') {
			$('.block-plan:first').clone(true).insertBefore(this);
			CountNumPlan();
			formClearPlan();
			swichButtonPlan();
		} else if (Type == 'remark') {
			$('.block-remark:first').clone(true).insertBefore(this);
			CountNumRemark();
			formClearRemark();
			swichButtonRemark();
			$('.block-remark').not(':first').find('.clone-hide').remove();
		} else if (Type == 'agreement') {
			$('.block-agreement:first').clone(true).insertBefore(this);
			CountNumAgreement();
			formClearAgreement();
			swichButtonAgreement();
		}
	});

	$('.delate').on('click', function(){
		var Type = $(this).data('type');
		var cloneBlock = '.block-' + Type;
		$(this).parents('.block-clone').remove();

		if (Type == 'plan') {
			CountNumPlan();
			swichButtonPlan();
		} else if (Type == 'remark') {
			CountNumRemark();
			swichButtonRemark();
		} else if (Type == 'agreement') {
			CountNumAgreement();
			swichButtonAgreement();
		}

	});

	function CountNumPlan() {
		$('.block-plan .count').each(function(i){
			$(this).text(i+1);
			$('.block-plan .delate').show();
		});
	}

	function formClearPlan() {
		var objPlan = $('.block-plan:last');
		objPlan.find('input:text').not('.default-val').val('');
		objPlan.find('select').val('0');
		objPlan.find('.txt-error').remove();
		objPlan.find('input,select').removeClass('ipt-error');
	}

	function swichButtonPlan() {
		var CountPlan = $('.block-plan').size();
		if (CountPlan > 11) {
			$('.add-plan').hide();
			$('.block-plan:last').css('margin-bottom','40px');
		} else {
			$('.add-plan').show();
			$('.block-plan:last').css('margin-bottom','0');
		}
		if (CountPlan < 2) {
			$('.block-plan .delate').hide();
		} else {
			$('.block-plan .delate').show();
		}
	}

	function CountNumRemark() {
		$('.block-remark .count').each(function(i){
			$(this).text(i+1);
			$('.block-remark .delate').show();
		});
	}

	function formClearRemark() {
		var objRemark = $('.block-remark:last');
		objRemark.find('input:text').not('.default-val').val('');
		objRemark.find('select').val('0');
		objRemark.find('input:checkbox').attr('checked', false);
		objRemark.find('.txt-error').remove();
		objRemark.find('input,select').removeClass('ipt-error');
	}

	function swichButtonRemark() {
		var CountRemark = $('.block-remark').size();
		if (CountRemark > 2) {
			$('.add-remark').hide();
		} else {
			$('.add-remark').show();
		}
		if (CountRemark < 2) {
			$('.block-remark .delate').hide();
		} else {
			$('.block-remark .delate').show();
			$('.block-remark:first .delate').hide();
		}
	}

	function CountNumAgreement() {
		$('.block-agreement .count').each(function(i){
			$(this).text(i+1);
			$('.block-agreement .delate').show();
		});
	}

	function formClearAgreement() {
		var objAgree = $('.block-agreement:last');
		objAgree.find('input:text').val('');
		objAgree.find('select').val('0');
		objAgree.find('.txt-error').remove();
		objAgree.find('input,select').removeClass('ipt-error');
	}

	function swichButtonAgreement() {
		var CountAgreement = $('.block-agreement').size();
		if (CountAgreement > 2) {
			$('.add-agreement').hide();
			$('.block-agreement:last').css('margin-bottom','40px');
		} else {
			$('.add-agreement').show();
			$('.block-agreement:last').css('margin-bottom','0');
		}
		if (CountAgreement < 2) {
			$('.block-agreement .delate').hide();
		} else {
			$('.block-agreement .delate').show();
		}
	}


	$('.btn-validate').click(function(){

		formErrorReset();

		$('.t-required:visible').each(function(){
			if (!$(this).val()) {
				$(this).addClass('ipt-error');
			}
		});

		$('.s-required:visible').each(function(){
			if ($(this).val() == '0') {
				$(this).addClass('ipt-error');
			}
		});

		$('.block-default:visible td').find('.ipt-error:first').parent().append('<p class="txt-error">必須項目です</p>');

		$('.num-validate:visible').each(function(){
			if ( $(this).val() != '' && $(this).val().match(/[^0-9]+/) ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">半角数字で入力してください</p>');
				if ( $(this).parent().find('.txt-error').size() > 1 ) {
					$(this).parent().find('.txt-error:last').remove();
				}
			}
		});

		$('.kana-validate:visible').each(function(){
			if ( $(this).val() != '' && !$(this).val().match(/^[ｧ-ﾝﾞﾟ ]*$/) ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">半角カナで入力してください</p>');
			}
		});

		$('.max-3:visible').each(function(){
			var Count3 = $(this).val().length;
			if ( Count3 != '' && Count3 > 3 ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">3文字以内で入力してください</p>');
			}
		});

		$('.max-4:visible').each(function(){
			var Count4 = $(this).val().length;
			if ( Count4 != '' && Count4 > 4 ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">4文字以内で入力してください</p>');
			}
		});

		$('.max-100:visible').each(function(){
			var Count100 = $(this).val().length;
			if ( Count100 != '' && Count100 > 100 ) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">100文字以内で入力してください</p>');
			}
		});

		var errorCount = $('.ipt-error').size();
		if (errorCount > 0) {
			$('html,body').animate({scrollTop: $('.ipt-error:first').offset().top-30}, 600);
			return false;
		}

	});

	function formErrorReset() {
		$('select,input,label').removeClass('ipt-error');
		$('.txt-error').remove();
	}

	$('.btn-submit').click(function(){
		formErrorReset();
		$('.t-required:visible').each(function(){
			if (!$(this).val()) {
				$(this).addClass('ipt-error');
				$(this).parent().append('<p class="txt-error">入力してください</p>');
			}
		});
		$('.file-required:visible').each(function(){
			if (!$(this).val()) {
				$(this).addClass('ipt-error');
				$(this).after('<p class="txt-error">選択してください</p>');
			}
		});
		var errorCount = $('.ipt-error').size();
		if (errorCount > 0) {
			return false;
		}
	});


});
