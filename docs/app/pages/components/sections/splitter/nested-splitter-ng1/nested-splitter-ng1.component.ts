import { Component, ViewEncapsulation, ChangeDetectionStrategy } from '@angular/core';
import { BaseDocumentationSection } from '../../../../../components/base-documentation-section/base-documentation-section';
import { ICodePenProvider } from '../../../../../interfaces/ICodePenProvider';
import { ICodePen } from '../../../../../interfaces/ICodePen';
import { DocumentationSectionComponent } from '../../../../../decorators/documentation-section-component';
import './wrapper/nested-splitter-wrapper.directive.js';

@Component({
    selector: 'uxd-nested-splitter-ng1',
    templateUrl: './nested-splitter-ng1.component.html',
    styleUrls: ['./nested-splitter-ng1.component.less'],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush
})
@DocumentationSectionComponent('ComponentsNestedSplitterNg1Component')
export class ComponentsNestedSplitterNg1Component extends BaseDocumentationSection implements ICodePenProvider {
    public codepen: ICodePen = {
        html: this.snippets.raw.layoutHtml,
        css: [this.snippets.raw.stylesCss]
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
