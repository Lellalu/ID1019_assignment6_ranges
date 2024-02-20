defmodule Seeds do
  def parse_file() do
    text = File.read!("sample.txt")
    text_split = String.split(text, "\n\n")
    seeds = parse_seeds(Enum.at(text_split, 0))
    [seeds | Enum.map(Enum.slice(text_split, 1, 7), &parse_map/1)]
  end

  def parse_seeds(seeds_str) do
    seeds_str_parts = String.split(seeds_str, ":")
    seeds_number_str = String.trim(Enum.at(seeds_str_parts, 1))
    Enum.map(String.split(seeds_number_str, " "), fn x -> elem(Integer.parse(x), 0) end)
  end

  def parse_map(map_str) do
    map_str_parts = String.split(map_str, "\n")
    map_row_parts = List.delete_at(map_str_parts, 0)
    map_row_parts = Enum.map(map_row_parts, fn x -> String.trim(x) end)
    Enum.reduce(Enum.map(map_row_parts, &parse_map_row/1), &Map.merge/2)
  end

  def parse_map_row(map_row_str) do
    map_row_parts = String.split(map_row_str, " ")
    map_row_parts = Enum.map(map_row_parts, fn x -> elem(Integer.parse(x), 0) end)
    create_map_from_row(map_row_parts, Map.new())
  end

  def create_map_from_row([dest, source, 1], map) do
    Map.put(map, source, dest)
  end

  def create_map_from_row([dest, source, range], map) do
    create_map_from_row(
      [dest, source, range-1], Map.put(map, source+range-1, dest+range-1))
  end

  def get_min_location() do
    [seeds, sts, stf, ftw, wtl, ltt, tth, htl] = parse_file()
    locations = Enum.map(seeds, fn(seed)->
      soil = Map.get(sts, seed, seed)
      fertilizer = Map.get(stf, soil, soil)
      water = Map.get(ftw, fertilizer, fertilizer)
      light = Map.get(wtl, water, water)
      temperature = Map.get(ltt, light, light)
      humidity = Map.get(tth, temperature, temperature)
      Map.get(htl, humidity, humidity)
    end)
    Enum.min(locations)
  end
end
