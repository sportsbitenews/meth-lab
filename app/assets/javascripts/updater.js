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

        showGraph: function(kpi,arrConVal,arrExpVals) {

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
                   '#2f7ed8', // color for control
                   '#0d233a', // color for experiment
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
                yAxis: {
                    title: {
                        text: null
                    },
                    endOnTick: true,
                    maxPadding: 0
                },
                tooltip: {
                    formatter: function() {
                        return this.series.name + ': <b>'+ this.x + '</b> / <b>'+ this.y +'%</b>';
                    }
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
                    name: 'Control',
                    data: arrConVal
                }, {
                    name: 'Experiment',
                    data: arrExpVals
                }]
            });
        }
    };

    window.experimentData = experimentData;

    $(document).ready(function() {
        experimentData.init();
    });

})(window, jQuery);