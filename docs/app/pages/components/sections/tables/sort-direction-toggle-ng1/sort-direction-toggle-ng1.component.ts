import { Component } from '@angular/core';
import { DocumentationSectionComponent } from '../../../../../decorators/documentation-section-component';
import { ICodePenProvider } from '../../../../../interfaces/ICodePenProvider';
import { ICodePen } from '../../../../../interfaces/ICodePen';
import { BaseDocumentationSection } from '../../../../../components/base-documentation-section/base-documentation-section';

@Component({
    selector: 'uxd-components-sort-direction-toggle',
    templateUrl: './sort-direction-toggle-ng1.component.html'
})
@DocumentationSectionComponent('ComponentsSortDirectionToggleNg1Component')
export class ComponentsSortDirectionToggleNg1Component extends BaseDocumentationSection implements ICodePenProvider {
    
    private htmlCode = this.snippets.compiled.sampleHtml;
    private jsCode = this.snippets.compiled.sampleJs;

    public codepen: ICodePen = {
        html: this.snippets.raw.sampleHtml,
        htmlAttributes: {
            'ng-controller': 'SortToggleCtrl as vm'
        },
        js: [this.snippets.raw.sampleJs]
    };
    
    constructor() {
        super(
            require.context('!!prismjs-loader?lang=html!./snippets/', false, /\.html$/),
            require.context('!!prismjs-loader?lang=css!./snippets/', false, /\.css$/),
            require.context('!!prismjs-loader?lang=javascript!./snippets/', false, /\.js$/),
            require.context('!!prismjs-loader?lang=typescript!./snippets/', false, /\.ts$/),
            require.context('./snippets/', false, /\.(html|css|js|ts)$/)
        );
    }
}