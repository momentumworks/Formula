
return '// MARK: - AutoHashable\n\n'
 + (extensions.AutoHashable || []).map(function(object) {
   if (object.isEnum && (object.extensions.includes("String") || object.extensions.includes("Int"))) {
     return ''
   }
   const equalityString = (object.isEnum) ? enumEquality(object) : structEquality(object)
   return `extension ${object.name}: Hashable {\n\n`
      + `  ${object.accessibility} var hashValue: Int {`
      + equalityString
      + '  }\n'
      + '}'
  }).join('\n\n')


function structEquality(object) {
  return 'return '
    + object.fields.map(function(field) {
      if (isArray(field.type)) {
        return `arrayHashValue(${field.name})`
      } else if (isDictionary(field.type)) {
        return `dictionaryHashValue(${field.name})`
      } else {
        return `${field.name}.hashValue`
      }
    }).join(' ^ ')
}

function enumEquality(object) {
  return 'switch (self) {\n'
    + object.enumCases.map (function (enumCase) {
        return `case (.${enumCase.name}`
          + listEnumAssociatedValues(enumCase)
          + '):\n'
          + `return ${listEnumAssociatedValuesHash(enumCase)}\n`
        }).join('\n')
    + '  }\n'
}


function listEnumAssociatedValues(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return '('
      + enumCase.associatedValues.map(function (associatedValue, index) {
          return `let value${index+1}`
        }).join(', ')
      + ')'
  } else {
    return ''
  }
}

function listEnumAssociatedValuesHash(enumCase) {
  if (enumCase.associatedValues != undefined && enumCase.associatedValues != null && enumCase.associatedValues.length > 0) {
    return enumCase.associatedValues.map(function (associatedValue, index) {
          if (isArray(associatedValue)) {
            return `arrayHashValue(value${index+1})`
          } else if (isDictionary(associatedValue)) {
            return `dictionaryHashValue(value${index+1})`
          } else {
            return `value${index+1}.hashValue`
          }
        }).join(' ^ ')
  } else {
    return `"${enumCase.name}".hashValue`
  }
}

function isArray(type) {
  return getArrayType(type) != null
}

function isDictionary(type) {
  return getDictionaryType(type) != null
}

function getArrayType(type) {
  if (type.startsWith('Array<') && type.endsWith('>')) {
    return type.slice(6, -1).trim()
  } else if (type.startsWith('[') && type.endsWith(']') && !type.includes(':')) {
    return type.slice(1, -1).trim()
  } else {
    return null
  }
}

function getDictionaryType(type) {
  console.log("getDictionaryType: type = " + type)
  if (type.startsWith('Dictionary<') && type.endsWith('>')) {
    var dictionaryTypes = type.slice(11, -1).split(",")
    console.log("dictionaryTypes = " + dictionaryTypes)
    return {keyType: dictionaryTypes[0].trim(), valueType: dictionaryTypes[1].trim()}
  } else if (type.startsWith('[') && type.endsWith(']') && type.includes(':')) {
    var dictionaryTypes = type.slice(1, -1).split(":")
    console.log("dictionaryTypes = " + dictionaryTypes)
    return {keyType: dictionaryTypes[0].trim(), valueType: dictionaryTypes[1].trim()}
  } else {
    return null
  }
}
