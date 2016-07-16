
return '// MARK: - AutoEquatable\n\n'
 + extensions.AutoEquatable.map(function(object) {
    return `${object.accessibility} func ==(lhs: ${object.name}, rhs:${object.name}) -> Bool {`
      + object.isEnum ? enumEquality(object) : structEquality(object)
  })


function structEquality(function(struct) {

})
function enumEquality(function(enum) {
  return 'switch (lhs, rhs) {'
    + enum.enumCases.map (function (enumCase) {
        return `case (.${enumCase.name}`
          + listEnumAssociatedValues(enumCase)
          + `, .${enumCase.name}`
          + listEnumAssociatedValues(enumCase)
          + 
        })
})

function listEnumAssociatedValues(function(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null & enumCase.associatedValues.length > 0) {
    return '('
      + enumCase.associatedValues.map(function (associatedValue, index) {
          return `let lhsValue${index}`
        }).join(',')
      + ')'
  } else {
    return ''
  }
})

function

//  {% if type.enumCases %}switch (lhs, rhs) { {% for enumCase in type.enumCases %}
//    case (.{{ enumCase.name }}{% if enumCase.associatedValues %}({% for associatedValue in enumCase.associatedValues %}let lhsValue{{ forloop.counter }}{% comma %}{% endfor %}){% endif %}, .{{ enumCase.name }}{% if enumCase.associatedValues %}({% for associatedValue in enumCase.associatedValues %}let rhsValue{{ forloop.counter }} {% comma %}{% endfor %}){% endif %}){% if enumCase.associatedValues %} where {% for associatedValue in enumCase.associatedValues %}lhsValue{{ forloop.counter }} == rhsValue{{ forloop.counter }} {% andSymbol %}{% endfor %}{% endif %}:
//      return true{% endfor %}
//    default: return false
//  }
//  {% else %}
//  return  {% for field in type.fields %}  lhs.{{ field.name }} == rhs.{{ field.name }} {% andSymbol %}
//  {% endfor %}{% endif %}
//}
