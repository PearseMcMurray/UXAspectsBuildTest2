angular.module('app').controller('CollapsiblePanelsDemoCtrl', CollapsiblePanelsDemoCtrl);

CollapsiblePanelsDemoCtrl.$inject = ['$timeout'];

function CollapsiblePanelsDemoCtrl($timeout) {
    var vm = this;

    vm.groups = [{
        title: 'Collapsible Panel 1',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum tincidunt est vitae ultrices accumsan. Aliquam ornare lacus adipiscing, posuere lectus et, fringilla augue.',
        isOpen: 'true'

    }, {
        title: 'Collapsible Panel 2',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum tincidunt est vitae ultrices accumsan. Aliquam ornare lacus adipiscing, posuere lectus et, fringilla augue.',
        isOpen: 'false'
    }, {
        title: 'Collapsible Panel 3',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum tincidunt est vitae ultrices accumsan. Aliquam ornare lacus adipiscing, posuere lectus et, fringilla augue.',
        isOpen: 'false'
    }];

    $timeout(function () {
        $(".panel-heading[data-toggle='collapse']").each(function (index, element) {
            $(element).keypress(function (e) {
                if (e.which === 13 || e.which === 32) {
                    $(element).trigger("click");
                }
            });
        });
    }, 200);
}