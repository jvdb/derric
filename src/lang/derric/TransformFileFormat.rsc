module lang::derric::TransformFileFormat

import List;
import Relation;
import Set;

import lang::derric::FileFormat;
import lang::derric::PropagateDefaultsFileFormat;
import lang::derric::testparse;

public void generateNoCA(loc path) {
    
    Field removeCA(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, ContentSpecifier specifier) {
        
        bool isTerminated(ContentSpecifier specifier) {
            s = domain(toSet(specifier.arguments));
            return "terminator" in s && "terminatorsize" in s && "includeterminator" in s;
        }
        
        Expression makeOr(list[Specification] values) {
            if (size(values) == 0) { throw "Empty list not supported."; }
            if (size(values) == 1) { return \value(values[0].i); }
            return or(\value(head(values).i), makeOr(tail(values)));
        }
        
        if (isTerminated(specifier)) {
            modifiers += terminator(getOneFrom(toMap(specifier.arguments)["includeterminator"])[0] == const("true"));
            qualifiers[5] = Qualifier::size(\value(getOneFrom(toMap(specifier.arguments)["terminatorsize"])[0].i/8))[@local=true];
            Expression specification = makeOr(getOneFrom(toMap(specifier.arguments)["terminator"]));
            return field(name, modifiers, qualifiers, specification);
        } else {
            return field(name, modifiers, qualifiers, noValue());
        }
    }
    
    FileFormat format = load(path);
    format.name += "NoCA";
    format = visit (format) {
        case f:field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, ContentSpecifier specifier)
            => removeCA(name, modifiers, qualifiers, specifier)[@location=f@location]
    }
    writeDerric(format);
}
