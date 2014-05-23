$(function() {
  $('input[type="submit"]').attr('disabled', 'disabled');
  $(".action-button").click(function() {
    $(".input-field").fadeIn( "slow" );
    $(".action-button").addClass("submit-state");
    $(".submit-state").click(function() {
      $('input[type="submit"]').removeAttr('disabled');
    });
  });
});

