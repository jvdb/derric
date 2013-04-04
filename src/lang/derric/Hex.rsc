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

Color baseColor = color("LemonChiffon");
Color selectStructureColor = color("Orange");
Color selectFieldColor = color("LightBlue");

list[str] chars = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ];

public str toHex8(int i) = chars[i / 16] + chars[i % 16];
public str toHex16(int i) = toHex8(i / 256) + toHex8(i % 256);
public str toHex32(int i) = toHex16(i / 65536) + toHex16(i % 65536);

public void show(loc derricFile, loc inputFile) {
    int activeStructure = 100;
    int activeField = 100;
    
    FileFormat format = load(derricFile);
    Validator validator = build(format);
    println("Validator:                <validator>");
    tuple[bool, list[tuple[str, loc, loc, loc, list[tuple[str, loc, loc]]]]] result = executeValidator(validator.format, format.sequence, validator.structs, validator.globals, inputFile);
    println("Validated: <result[0]>");
    println("Matches:");
    for (<name, seql, strl, inpl, flds> <- result[1]) {
        println("<name>: seq(<seql.offset>, <seql.length>), str(<strl.offset>, <strl.length>), inp(<inpl.offset>, <inpl.length>)");
        for (<fname, fsl, fil> <- flds) {
            println("  <fname>: src(<fsl.offset>, <fsl.length>), inp(<fil.offset>, <fil.length>)");
        }
    }
    
    list[int] bytes = readFileBytes(inputFile);
    
    Figure makeStructureView() {
        lines = [[box(
            text(result[1][i][0]),
            fillColor(Color () { if (i == activeStructure) { return selectStructureColor; } else { return baseColor; } }),
            onMouseDown(bool (int b, map[KeyModifier, bool] m) {
                if (b == 1) {
                    activeStructure = i;
                    activeField = 100;
                    return true;
                } else if (b == 3) {
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
    
    Figure makeFieldView() {
        return computeFigure(Figure () {
    	    if (activeStructure < size(result[1])) {
                lines = [[box(
                    text(result[1][activeStructure][4][j][0]),
	    		    fillColor(Color () { if (j == activeField) { return selectFieldColor; } else { return baseColor; } }),
	    		    onMouseDown(bool (int b, map[KeyModifier, bool] m) {
	    		        activeField = j;
	    			   return true;
	    		    }))] | j <- [0..size(result[1][activeStructure][4])-1]];
	    	return box(
                grid(
                    lines,
					left(),
					top()
				),
                fillColor(baseColor),
                size(1, 1),
                resizable(false));
            } else {
                return space(
                    size(1, 1),
                    resizable(false)
                );
            }
        });
    }
    
    Figure makeCell(int i) = box(text("<toHex8(bytes[i])>"),
                                 size(20, 10),
                                 resizable(false),
                                 fillColor(Color () {
                                    for (s <- [0..size(result[1])-1], s == activeStructure, i >= result[1][s][3].offset, i < result[1][s][3].offset+result[1][s][3].length) {
                                    	if (activeField < size(result[1][s][4]) && i >= result[1][s][4][activeField][2].offset && i < result[1][s][4][activeField][2].offset+result[1][s][4][activeField][2].length) {
                                    		return selectFieldColor;
                                    	} else {
                                        	return selectStructureColor;
                                    	}
                                    }
                                    return baseColor;
                                 }),
                                 onMouseDown(bool (int b, map[KeyModifier, bool] m) {
                                    for (s <- [0..size(result[1])-1], i >= result[1][s][3].offset, i < result[1][s][3].offset+result[1][s][3].length) {
                                        for (f <- [0..size(result[1][s][4])-1], i >= result[1][s][4][f][2].offset, i < result[1][s][4][f][2].offset+result[1][s][4][f][2].length) {
                                            if (b == 1) {
                                                activeStructure = s;
                                                activeField = f;
                                            } else if (b == 3) {
                                                edit(result[1][s][1], [highlight(result[1][s][1].begin.line, "Sequence"), highlight(result[1][s][2].begin.line, "Structure"), highlight(result[1][s][4][f][1].begin.line, "Field")]);
                                            }
                                            return true;
                                        }
                                    }
                                    activeStructure = 100;
                                    return true;
                                 }));
    
    Figure makeHexView() {
        lines = for (i <- [0 .. (size(bytes) / 16)]) {
            line = [box(text("<toHex32(i*16)>"), fillColor("LightGray"), size(60, 10), resizable(false))];
            line += for (j <- [0 .. 15], (i*16)+j < size(bytes)) {
                append makeCell((i*16)+j);
            }
            if (size(line) > 1) {
            	append line;
            }
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
    Figure m = makeFieldView();
	Figure r = makeHexView();
	render(grid([[l, m, r]]));
}
