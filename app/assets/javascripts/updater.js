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

            // bind event to show graph
            $(document.body).on('click', '.js-experiment-data .js-data-main', function(e) {
                e.preventDefault();
                $(this).toggleClass('graph-active');
            });

            // bind show/hide all graphs
            $(document.body).on('click', '.graph-toggle .js-graphs-show', function(e) {
                e.preventDefault();
                $('.js-experiment-data .js-data-main').addClass('graph-active');
            });

            $(document.body).on('click', '.graph-toggle .js-graphs-hide', function(e) {
                e.preventDefault();
                $('.js-experiment-data .js-data-main').removeClass('graph-active');
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

    window.experimentData = experimentData;

    $(document).ready(function() {
        experimentData.init();
    });

})(window, jQuery);