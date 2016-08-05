

return '// MARK: - JSONEncodable\n\n'
 + extensions.AutoJSONEncodable.map(function(object) {
    if (object.isEnum) {
      return `extension ${object.name} : JSONEncodable {\n`
        + `  static func fromJSON(optionalJSON: JSON?) -> ${object.name}? {`
        + `    return optionalJSON.string.flatMap { ${object.name}(rawValue: $0.lowercaseString }\n}\n`
        + `  func toJSON() -> JSON {`
        + `    return JSON(self.rawValue.lowercaseString)\n}\n}\n`
    } else {
      return ''
    }
  }).join('\n\n')
