# Goal

Quiero poder usar gf o dejado para quien quiera para ir a la defincion del archivo
de view, Route::view, config & env

- [ ] Get node at cursor, and validate that is in string on one of the supported functions.
- [ ] get the needed information of the file
- [ ] for config and env should get to the line were defined.
- [ ] for config will be a bit hard, need to get the file name from the first part

need to use function get_node_at_cursor(winnr)
From that I need to get the parser, and get the termins

get_node_text({node}, {source}, {opts})
source can be the buf number
nvim_get_current_buf should be able to use it, or 0
