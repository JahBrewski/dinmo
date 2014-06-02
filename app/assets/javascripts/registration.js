$(function() {

  if (is_homepage()) {
    init();
  }

  function init() {

    if (getParameterByName('failed') == 'y') {
      failed_registration_state();
    } else {
      initial_state();
    }
  }

  function is_homepage() {
    if ($(".static_pages-home").length) {
      return true
    } else {
      return false
    }
  }

  function failed_registration_state() {
    show_input_fields();
    $(".absolute-center").css("margin-top", "0");
  }

  function initial_state() {
    disable_submit_button();
    action_button_handler();
  }

  function disable_submit_button() {
  $('input[type="submit"]').attr('disabled', 'disabled');
  }

  function action_button_handler() {
   $(".action-button").click(function() {
     fade_in_input_fields();
     $(".action-button").addClass("submit-state");
     $(".submit-state").click(function() {
       activate_submit_button();
     });
   });
  }

  function activate_submit_button() {
   $('input[type="submit"]').removeAttr('disabled');
  }

  function fade_in_input_fields() {
   $(".hidden-input-field").fadeIn( "slow" );
  }

  function show_input_fields() {
   $(".hidden-input-field").show();
  }

  function getParameterByName(name) {
      name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
      var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
          results = regex.exec(location.search);
      return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  }
});
