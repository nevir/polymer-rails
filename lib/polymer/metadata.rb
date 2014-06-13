require 'set'

module Polymer
  module Metadata
    RESERVED_ELEMENT_NAMES = Set.new([
      # Lifecycle Methods
      'created',
      'ready',
      'attached',
      'domReady',
      'detached',
      'attributeChanged',
      # DOM
      'accessKey',
      'attributes',
      'baseURI',
      'childElementCount',
      'childNodes',
      'children',
      'classList',
      'className',
      'clientHeight',
      'clientLeft',
      'clientTop',
      'clientWidth',
      'contentEditable',
      'dataset',
      'dir',
      'draggable',
      'firstChild',
      'firstElementChild',
      'hidden',
      'id',
      'innerHTML',
      'innerText',
      'isContentEditable',
      'lang',
      'lastChild',
      'lastElementChild',
      'localName',
      'namespaceURI',
      'nextElementSibling',
      'nextSibling',
      'nodeName',
      'nodeType',
      'nodeValue',
      'offsetHeight',
      'offsetLeft',
      'offsetParent',
      'offsetTop',
      'offsetWidth',
      'outerHTML',
      'outerText',
      'ownerDocument',
      'parentElement',
      'parentNode',
      'prefix',
      'previousElementSibling',
      'previousSibling',
      'scrollHeight',
      'scrollLeft',
      'scrollTop',
      'scrollWidth',
      'shadowRoot',
      'spellcheck',
      'style',
      'tabIndex',
      'tagName',
      'textContent',
      'title',
      'translate',
    ])
    RESERVED_ELEMENT_NAME_MATCHERS = [
      proc { |name| RESERVED_ELEMENT_NAMES.include? name },
      proc { |name| name.start_with? 'on' },
      proc { |name| name.end_with? 'Changed' },
    ]

    def self.reserved_name?(name)
      RESERVED_ELEMENT_NAME_MATCHERS.any? { |m| m.call(name) }
    end
  end
end
