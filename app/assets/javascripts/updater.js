(function (window, $, undefined) {
    "use strict";

    var experimentData = {

        experimentDataInterval: null,
        experimentDataTimer: 0,
        experimentDataTimerEnd: 600, // 10 minutes

        init: function() {

            var dataDiv     = $('[data-ajax="true"]'),
                divTarget   = dataDiv.data('target'),
                divInterval = dataDiv.data('interval'),
                that        = this;

            if (dataDiv.length > 0) {
                that.experimentDataInterval = window.setInterval(function() {
                    that.updateData(dataDiv,divTarget);
                    that.experimentDataTimer = that.experimentDataTimer + divInterval;
                }, parseInt(divInterval*1000));
            }

            // bind event to show graph
            $(document.body).on('click', '.js-experiment-data .js-data-main', function(e) {
                e.preventDefault();
                $(this).toggleClass('graph-active');
            });

            // bind show/hide all graphs
            $(document.body).on('click', '.js-graph-toggle .js-graphs-show', function(e) {
                e.preventDefault();
                $('.js-experiment-data .js-data-main').addClass('graph-active');
            });

            $(document.body).on('click', '.js-graph-toggle .js-graphs-hide', function(e) {
                e.preventDefault();
                $('.js-experiment-data .js-data-main').removeClass('graph-active');
            });

            $(document.body).on('click', '.js-graph-toggle .js-graphs-resume', function(e) {
                e.preventDefault();
                $('.js-graphs-resume-wrap').remove();
                // restart pushing service
                that.experimentDataTimer = 0;
                that.experimentDataInterval = window.setInterval(function() {
                    that.updateData(dataDiv,divTarget);
                    that.experimentDataTimer = that.experimentDataTimer + divInterval;
                }, parseInt(divInterval*1000));

            });

        },

        updateData: function(ele,target) {

            var arrGraphRows = [];

            if ($(ele).find('.js-experiment-data').length > 0) {

                // add min-height to element so it doesn't jump
                var wrapHeight = $(ele).innerHeight();
                $(ele).css('min-height',wrapHeight + 'px');

                // figure out which graph rows are open
                $(ele).find('.js-experiment-data .js-data-main').each(function(i) {
                    if ($(this).hasClass('graph-active')) {
                        arrGraphRows.push($(this).attr('data-kpi'));
                    }
                });
            }

            $.ajax({
                type     : 'get',
                url      : target,
                cache    : false,
                async    : true,
                dataType : 'html',
                success:function(response) {
                    $(ele).empty();
                    $(ele).append(response);

                    // hack to ensure graphs remain open
                    if (arrGraphRows.length > 0) {
                        $.each(arrGraphRows, function(i, val) {
                            $(ele).find('.js-experiment-data .js-data-main[data-kpi="' + val + '"]').addClass('graph-active');
                        });
                    }

                    // remove min-height
                    $(ele).css('min-height','0px');

                    // stop push if we're past timer
                    if (experimentData.experimentDataTimer > experimentData.experimentDataTimerEnd) {
                        window.clearInterval(experimentData.experimentDataInterval);
                        $('.js-graph-toggle').append('<span class="js-graphs-resume-wrap">| Data Pulling Paused. <a href="#" class="js-graphs-resume">Resume?</a></span>');
                    }
                }
            });
        },

        showGraph: function(kpi,timelineDataObj) {

            var arrExpVals   = [],
                startTime    = document.pageScope.startTime,
                startTimeArr = [],
                startYear    = 0,
                startMonth   = 0,
                startDay     = 0;

            // format start time
            startTimeArr = startTime.split(" ");
            startTimeArr = startTimeArr[0].split("-");
            startYear = parseInt(startTimeArr[0]);
            startMonth = parseInt(startTimeArr[1]);
            startDay = parseInt(startTimeArr[2]);

            // get values 
            $.each(timelineDataObj.performance, function(k, val) {
                arrExpVals.push(val);
            });

            // show the graph
            $('.js-highchart-' + kpi).highcharts({
                chart: {
                    height: 100,
                    width: 938,
                    type: 'line',
                    animation: false,
                    ignoreHiddenSeries: true
                },
                colors: [
                   '#2f7ed8', // color for line
                   '#0d233a',
                   '#8bbc21', 
                   '#910000', 
                   '#1aadce', 
                   '#492970',
                   '#f28f43', 
                   '#77a1e5', 
                   '#c42525', 
                   '#a6c96a'
                ],
                credits: {
                    enabled: false
                },
                title: {
                    text: 'Graph',
                    style: {
                        display: 'none'
                    }
                },
                xAxis: {
                    type: 'datetime'
                },
                yAxis: {
                    title: {
                        text: null
                    },
                    endOnTick: true,
                    maxPadding: 0,
                    plotLines: [{
                        color: '#FF4D4D',
                        width: 2,
                        value: 0
                    }]
                },
                legend: {
                    layout: 'vertical',
                    align: 'right',
                    verticalAlign: 'middle',
                    borderWidth: 0
                },
                plotOptions: {
                    series: {
                        lineWidth: 1,
                        threshold: 0,
                        marker: {
                            enabled: false,
                            states: {
                                hover: {
                                    enabled: true
                                }
                            }
                        }
                    }
                },
                series: [{
                    name: 'Performance',
                    data: arrExpVals,
                    pointStart: Date.UTC(startYear, (startMonth-1), startDay),
                    pointInterval: 3600000 // 1 hour
                }]
            });
        }
    };

    var experimentConfigure = {

        init: function() {

            // bind select all checkbox
            if ($('.js-configure-kpi-global').length > 0) {
                $('.js-configure-kpi-global').change(function() {
                    if (this.checked) {
                        $(this).closest('.control-group').find('.controls input[type="checkbox"]').prop('checked', true);
                    } else {
                        $(this).closest('.control-group').find('.controls input[type="checkbox"]').prop('checked', false);
                    }
                });
            }

            // bind add new kpi element
            if ($('.js-configure-kpi-empty').length > 0) {
                $('.js-btn-configure-kpi-empty').click(function(e) {
                    e.preventDefault();
                    if ($('.js-configure-kpi-empty').val() != '') {
                        $('.js-configure-kpi-empty').before('<input id="experiment_tracked_kpis_" name="experiment_tracked_kpis[]" type="text" value="' + $('.js-configure-kpi-empty').val() + '">');
                        $('.js-configure-kpi-empty').val('');
                    }
                });
            }

        }

    };

    window.experimentData = experimentData;
    window.experimentConfigure = experimentConfigure;

    $(document).ready(function() {
        experimentData.init();
        experimentConfigure.init();
    });

})(window, jQuery);