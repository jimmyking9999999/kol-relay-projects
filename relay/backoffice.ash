string store = visit_url();
void parse_sales_activity() {

buffer page;
string[int] store_lines = store.split_string('Meat.');

string[int] parse(string parse_line) {

    string[int] parsed_result;

    matcher line_matcher = create_matcher(":\\d+ (.+) bought (\\d+) \\((.*?)\\) for (\\d+)", parse_line);

    if(line_matcher.find()){
        parsed_result[0] = line_matcher.group(1);
        parsed_result[1] = line_matcher.group(2);
        parsed_result[2] = line_matcher.group(3);
        parsed_result[3] = line_matcher.group(4);
    }
    return parsed_result;
}

string convert_commas(int number) { 
	return replace_all(create_matcher("(?<!\\.\\d*)\\B(?=(\\d{3})+(?!\\d))", number), ",");
}

string[int] parsed_result;
buffer chart_lines;

int[string, string] sales;

foreach x, it in store_lines {
    // 0 -> Name, 1 -> Amnt, 2 -> item, 3 -> Price
    parsed_result = parse(it);

    sales["sale_meat", parsed_result[2]] += parsed_result[3].to_int();
    sales["sale_amount", parsed_result[2]] += parsed_result[1].to_int();
    sales["transactions", parsed_result[2]] += 1;

}

foreach x, item_name in sales {

    if(item_name == "" || x != "sale_meat"){
        continue;
    }

    chart_lines.append('<tr>');
    chart_lines.append(`<td><b>{item_name}</b></td>`);
    chart_lines.append(`<td>{(sales["sale_amount", item_name]).convert_commas()}</td>`);
    chart_lines.append(`<td>{(sales["transactions", item_name]).convert_commas()}</td>`);
    chart_lines.append(`<td>{(sales["sale_amount", item_name]/sales["transactions", item_name]).convert_commas()}</td>`);
    chart_lines.append(`<td>{(sales["sale_meat", item_name]).convert_commas()}</td>`);
    chart_lines.append(`<td>{(sales["sale_meat", item_name]/sales["sale_amount",item_name]).convert_commas()}</td>`);
    chart_lines.append('</tr>');

}

store = store.replace_string("past 2 weeks)", '<!DOCTYPE html><html lang="en"><head><link rel="stylesheet" href="styles.css"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Lexend:wght@400;700&display=swap"><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Sales Table</title><link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.css"><script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.6.0.min.js"></script><script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.js"></script><link rel="stylesheet" href="styles.css"></head> past 2 weeks) <body><style>* {font-family: "Lexend", sans-serif;}</style><table id="sales-table" class="sales-table"><thead><tr><th>Item</th><th>Total Sold</th><th>Total Transactions</th><th>Avg. Sold Per Trans.</th><th>Total Meat</th><th>Average Price</th></tr></thead><tbody>' + chart_lines + '</tbody></table><script>$(document).ready(function()' +  "{$('#sales-table').DataTable();});</script></body></html>");
write(store);

}

void main(){
    if(!store.contains_text("Recent Store Activity (past 2 weeks)")){
        write(store);
    } else {
        parse_sales_activity();
    }

}
