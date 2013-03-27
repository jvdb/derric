module lang::derric::Hex

import IO;
import List;
import Map;
import Set;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::derric::FileFormat;
import lang::derric::testparse;
import lang::derric::Validator;
import lang::derric::BuildValidator;
import lang::derric::ExecuteValidator;

str baseColor = "LemonChiffon";

list[str] chars = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ];

public str toHex8(int i) = chars[i / 16] + chars[i % 16];
public str toHex16(int i) = toHex8(i / 256) + toHex8(i % 256);
public str toHex32(int i) = toHex16(i / 65536) + toHex16(i % 65536);

public void show(loc derricFile, loc inputFile) {
    Color baseColor = color("LemonChiffon");
    Color selectColor = color("Orange");
    int activeStructure = 0;
    
    FileFormat format = load(derricFile);
    Validator validator = build(format);
    println("Validator:                <validator>");
    tuple[bool, list[tuple[str, loc, loc, loc]]] result = executeValidator(validator.format, format.sequence, validator.structs, validator.globals, inputFile);
    println("Validated: <result[0]>");
    println("Matches:");
    for (<name, seql, strl, inpl> <- result[1]) {
        println("<name>: seq(<seql.offset>, <seql.length>), str(<strl.offset>, <strl.length>), inp(<inpl.offset>, <inpl.length>)");
    }
    
    list[int] bytes = readFileBytes(inputFile);
    
    Figure makeStructureView() {
        lines = [[box(
            text(result[1][i][0]),
            fillColor(Color () { if (i == activeStructure) { return selectColor; } else { return baseColor; } }),
            onMouseDown(bool (int b, map[KeyModifier, bool] m) {
                if (b == 1) {
                    activeStructure = i;
                    return true;
                } else if (b == 3) {
                    println("right click! show: <result[1][i][1]>");
                    edit(result[1][i][1], [highlight(result[1][i][1].begin.line, "Sequence"), highlight(result[1][i][2].begin.line, "Structure")]);
                    return true;
                }
                return false;
            }))] | i <- [0..size(result[1])-1]];
        return box(
                    grid(
                        lines,
                        left(),
                        top()
                    ),
                    fillColor(baseColor),
                    size(1, 1),
                    resizable(false)
                );
    }
    
    Figure makeCell(int i) = box(text("<toHex8(bytes[i])>"), size(20, 10), resizable(false), fillColor(Color () {
        for (s <- [0..size(result[1])-1], s == activeStructure, i >= result[1][s][3].offset, i < result[1][s][3].offset+result[1][s][3].length) {
            return selectColor;
        }
        return baseColor;
    }));
    
    Figure makeHexView() {
        lines = for (i <- [0 .. (size(bytes) / 16)]) {
            line = [box(text("<toHex32(i*16)>"), fillColor("LightGray"), size(60, 10), resizable(false))];
            line += for (j <- [0 .. 15], (i*16)+j < size(bytes)) {
                append makeCell((i*16)+j);
            }
            append line;
        }
        return vscrollable(
                    box(
                        grid(
                            lines,
                            left(),
                            top()
                        ),
                        size(1, 1),
                        resizable(false)
                    ),
                    vsize(226),
                    resizable(false)
                );
    }
    
    Figure l = makeStructureView();
	Figure r = makeHexView();
	render(grid([[l, r]]));
}
