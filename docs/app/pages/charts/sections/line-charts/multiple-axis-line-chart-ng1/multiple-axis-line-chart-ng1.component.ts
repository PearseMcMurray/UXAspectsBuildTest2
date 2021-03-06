import { Component, Inject, ChangeDetectionStrategy } from '@angular/core';
import { DocumentationSectionComponent } from '../../../../../decorators/documentation-section-component';
import { ICodePen } from '../../../../../interfaces/ICodePen';
import { ICodePenProvider } from '../../../../../interfaces/ICodePenProvider';
import { ColorService } from '../../../../../../../src/index';

@Component({
  selector: 'uxd-charts-multiple-axis-line-chart-ng1',
  templateUrl: './multiple-axis-line-chart-ng1.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
@DocumentationSectionComponent('ChartsMultipleAxisLineChartNg1Component')
export class ChartsMultipleAxisLineChartNg1Component implements ICodePenProvider {

  private data: any[];
  private options: any;

  private htmlCode = require('./snippets/chart.html');
  private jsCode = require('./snippets/chart.js');

  public codepen: ICodePen = {
    html: this.htmlCode,
    htmlAttributes: {
      'ng-controller': 'MultipleAxisLineChartCtrl as lc'
    },
    js: [this.jsCode]
  };

  constructor(colorService: ColorService, @Inject('flotDataService') flotDataService: any) {

    let flotChartColors = {
      chart1Color: colorService.getColor('chart1').toRgb(),
      chart2Color: colorService.getColor('chart2').toRgb(),
      gridColor: colorService.getColor('grey4').toHex(),
      tickColor: colorService.getColor('grey6').toHex(),
      borderColor: colorService.getColor('grey2').setAlpha(0.5).toRgba()
    };

    let oilprices = flotDataService.getOilPrices();

    let exchangerates = flotDataService.getExchangeRates();

    this.data = [{
      data: oilprices,
      label: 'Oil price ($)',
      lines: {
        show: true,
        fill: true,
        lineWidth: 1,
        fillColor: {
          colors: [{
            opacity: 0.1
          }, {
            opacity: 0.1
          }]
        }
      },
      shadowSize: 0,
      highlightColor: [flotChartColors.chart1Color]
    }, {
      data: exchangerates,
      label: 'USD/EUR exchange rate',
      yaxis: 2,
      lines: {
        show: true,
        fill: true,
        lineWidth: 1,
        fillColor: {
          colors: [{
            opacity: 0.2
          }, {
            opacity: 0.2
          }]
        }
      },
      shadowSize: 0,
      highlightColor: [flotChartColors.chart2Color]
    }];

    this.options = {
      xaxes: [{
        mode: 'time'
      }],
      yaxes: [{
        min: 0
      }, {
        // align if we are to the right
        position: 'right',
        alignTicksWithAxis: 1,
        tickFormatter: this.euroFormatter
      }],
      legend: {
        position: 'sw'
      },
      colors: [flotChartColors.chart1Color, flotChartColors.chart2Color],
      grid: {
        color: [flotChartColors.gridColor],
        clickable: true,
        tickColor: [flotChartColors.tickColor],
        borderWidth: {
          'bottom': 1,
          'left': 1,
          'top': 0,
          'right': 0
        },
        borderColor: {
          'bottom': [flotChartColors.borderColor],
          'left': [flotChartColors.borderColor]
        },
        hoverable: true // IMPORTANT! this is needed for tooltip to work,
      },
      tooltip: {
        show: true,
        shifts: {
          x: 0,
          y: -35
        },
        content: '%s for %x was %y',
        xDateFormat: '%y-%0m-%0d'
      }
    };
  }

  euroFormatter(v: number, axis: any) {
    return v.toFixed(axis.tickDecimals) + '€';
  }

}