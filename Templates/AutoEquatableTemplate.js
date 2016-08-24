
return '// MARK: - AutoEquatable\n\n'
 + (extensions.AutoEquatable || []).map(function(object) {
   const equalityString = (object.isEnum) ? enumEquality(object) : structEquality(object)
   return `extension ${object.name}: Equatable {}\n\n`
      + `${object.accessibility} func ==(lhs: ${object.name}, rhs:${object.name}) -> Bool {`
      + equalityString
      + '}\n'
  }).join('\n')


function structEquality(object) {
  return 'return '
    + object.fields.map(function(field) {
      return `  lhs.${field.name} == rhs.${field.name}`
    }).join(' &&\n')
}

function enumEquality(object) {
  return 'switch (lhs, rhs) {\n'
    + object.enumCases.map (function (enumCase) {
        return `case (.${enumCase.name}`
          + listEnumAssociatedValues(enumCase, 'lhs')
          + `, .${enumCase.name}`
          + listEnumAssociatedValues(enumCase, 'rhs')
          + ')'
          + listEnumAssociatedValuesEquality(enumCase)
          + ':\n return true\n'
        }).join('\n')
    + '  default: return false\n'
    + '  }\n'
}


function listEnumAssociatedValues(enumCase, prefix) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return '('
      + enumCase.associatedValues.map(function (associatedValue, index) {
          return `let ${prefix}Value${index+1}`
        }).join(', ')
      + ')'
  } else {
    return ''
  }
}

function listEnumAssociatedValuesEquality(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return 'where '
      + enumCase.associatedValues.map(function (associatedValue, index) {
          return `lhsValue${index+1} == rhsValue${index+1}`
        }).join(' && ')
  } else {
    return ''
  }
}
