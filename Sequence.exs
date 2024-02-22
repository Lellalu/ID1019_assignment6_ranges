defmodule SeedsImprove do
  def parse_file() do
    text = File.read!("sample.txt")
    text_split = String.split(text, "\n\n")
    seeds = parse_seeds(Enum.at(text_split, 0))
    [seeds | Enum.map(Enum.slice(text_split, 1, 7), &parse_map/1)]
  end

  def parse_seeds(seeds_str) do
    seeds_str_parts = String.split(seeds_str, ":")
    seeds_number_str = String.trim(Enum.at(seeds_str_parts, 1))
    [seq_a_start, seq_a_size, seq_b_start, seq_b_size] = Enum.map(String.split(seeds_number_str, " "), fn x -> elem(Integer.parse(x), 0) end)
    seq_a = range(seq_a_start, seq_a_start+seq_a_size-1)
    seq_b = range(seq_b_start, seq_b_start+seq_b_size-1)
    union(seq_a, seq_b)
  end

  def parse_map(map_str) do
    map_str_parts = String.split(map_str, "\n")
    map_row_parts = List.delete_at(map_str_parts, 0)
    map_row_parts = Enum.map(map_row_parts, fn x -> String.trim(x) end)
    Enum.reduce(Enum.map(map_row_parts, &parse_map_row/1), &(&1 ++ &2))
  end

  def parse_map_row(map_row_str) do
    map_row_parts = String.split(map_row_str, " ")
    [dest, src, size] = Enum.map(map_row_parts, fn x -> elem(Integer.parse(x), 0) end)
    [{range(src, src+size-1), dest-src}]
  end

  def get_location() do
    [seeds, sts, stf, ftw, wtl, ltt, tth, htl] = parse_file()
    soil = get_mapped_location(seeds, sts)
    fertilizer = get_mapped_location(soil, stf)
    water = get_mapped_location(fertilizer, ftw)
    light = get_mapped_location(water, wtl)
    temperature = get_mapped_location(light, ltt)
    humidity = get_mapped_location(temperature, tth)
    location = get_mapped_location(humidity, htl)
    if length(location) == 0 do
      nil
    else
      Enum.at(Enum.at(location, 0), 0)
    end
  end

  def get_mapped_location(seeds, map) do
    mapped_location = Enum.reduce(Enum.map(map, fn({range, diff}) ->
      inter = intersection(seeds, range)
      add(inter, diff)
    end), &union/2)

    mapped_source_location = Enum.reduce(
      Enum.map(map, fn({range, _}) -> range end), &union/2)
    not_mapped_location = difference(seeds, mapped_source_location)
    union(mapped_location, not_mapped_location)
  end

  def sts(seeds, sts_map) do
    soil = Enum.map(seeds, fn(seed)->
      [first|rest] = sts_map

    end)
  end

  def min(list) do
    Enum.min(list)
  end

  def empty() do [] end
  def range(from, to) do
    [from..to]
  end

  def union([], []) do
    []
  end
  def union([], seq_b) do
    seq_b
  end
  def union(seq_a, []) do
    seq_a
  end
  def union([start_a..end_a | rest_a], [start_b..end_b | rest_b]) do
    cond do
      # Disjoint cases
      start_b > end_a -> [start_a..end_a] ++ union(rest_a, [start_b..end_b | rest_b])
      start_a > end_b -> [start_b..end_b] ++ union([start_a..end_a | rest_a], rest_b)

      true -> [min(start_a, start_b)..max(end_a, end_b)] ++ union(rest_a, rest_b)
    end
  end

  def intersection(_, []) do
    []
  end
  def intersection([], _) do
    []
  end
  def intersection([start_a..end_a | rest_a], [start_b..end_b | rest_b]) do
    cond do
      # Disjoint cases
      start_b > end_a -> intersection(rest_a, [start_b..end_b | rest_b])
      start_a > end_b -> intersection([start_a..end_a | rest_a], rest_b)

      end_a < end_b -> [max(start_a, start_b)..min(end_a, end_b)] ++ intersection(rest_a, [end_a+1..end_b | rest_b])
      end_b < end_a -> [max(start_a, start_b)..min(end_a, end_b)] ++ intersection([end_b+1..end_a | rest_a], rest_b)
      true -> [max(start_a, start_b)..min(end_a, end_b)] ++ intersection(rest_a, rest_b)
    end
  end

  def difference(seq_a, []) do
    seq_a
  end
  def difference([], _) do
    []
  end
  def difference([start_a..end_a | rest_a], [start_b..end_b | rest_b]) do
    cond do
      start_b > end_a -> [start_a..end_a] ++ difference(rest_a, [start_b..end_b | rest_b])
      start_a > end_b -> difference([start_a..end_a | rest_a], rest_b)

      min(start_a, start_b-1) == start_a -> [start_a..start_b-1] ++ difference([start_b..end_a | rest_a], [start_b..end_b | rest_b])
      start_a >= start_b && end_a > end_b -> difference([end_b+1..end_a | rest_a], rest_b)

      true -> difference(rest_a, [start_b..end_b | rest_b])
    end
  end

  def add(seq, n) do
    add(seq, n, [])
  end
  def add([], _, acc) do
    acc
  end
  def add([s..e | r], n, acc) do
    add(r, n, acc ++ [s+n..e+n])
  end
end
