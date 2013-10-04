(function (window, $, undefined) {
    "use strict";

    var experimentData = {

        experimentDataInterval: null,

        init: function() {

            var dataDiv     = $('[data-ajax="true"]'),
                divTarget   = dataDiv.data('target'),
                divInterval = dataDiv.data('interval');

            if (dataDiv.length > 0) {
                experimentData.experimentDataInterval = window.setInterval(function() {
                    experimentData.updateData(dataDiv,divTarget)
                }, parseInt(divInterval*1000));
            }

        },

        updateData: function(ele,target) {
            $.ajax({
                type     : 'get',
                url      : target,
                cache    : false,
                async    : true,
                dataType : 'html',
                success:function(response) {
                    $(ele).empty();
                    $(ele).append(response);
                    console.log(response);
                }
            });
        }
    };

    window.experimentData = experimentData;

    $(document).ready(function() {
        experimentData.init();
    });

})(window, jQuery);