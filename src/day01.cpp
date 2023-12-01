
#include <algorithm>
#include <array>
#include <charconv>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <numeric>
#include <string>
#include <string_view>
#include <vector>

namespace {

template <typename T>
inline T Parse(std::string_view original, int base = 10) {
  T result;
  const auto [ptr, ec] = std::from_chars(original.data(), original.data() + original.size(), result, base);
  if (ec != std::errc())
    throw std::runtime_error("Fail to parse");
  return result;
}

std::string ReadToString(const std::string &filename) {
  std::ifstream infile(filename, std::ios::in | std::ios::binary);
  if (!infile.is_open())
    throw std::runtime_error("File Not Found");

  // Obtain the size of the file.
  const auto sz = std::filesystem::file_size(filename);
  // Create a buffer.
  std::string input_raw(sz, '\0');
  // Read the whole file into the buffer.
  infile.read(input_raw.data(), sz);
  return input_raw;
}

// Iterator on a string splitted by a delimiter (default:'\n')
// Usage:
//   - range loop :
//       for (auto line : IteratorOnLines(input_raw)) {
//   - vector initialization :
//       std::vector<std::string_view>(IteratorOnLines(input_raw).begin(), IteratorOnLines(input_raw).end())
class IteratorOnLines {

public:
  using iterator_category = std::input_iterator_tag;
  using difference_type = std::ptrdiff_t;
  using value_type = std::string_view;
  using pointer = value_type;
  using reference = value_type &;

  IteratorOnLines(std::string_view input_raw, const char delimiter = '\n')
      : input_raw(input_raw), delimiter(delimiter) {
    next = input_raw.find(delimiter, start);
    line = std::string_view{input_raw.data() + start, next - start};
  }

  IteratorOnLines &begin() {
    return *this;
  }
  // The end iterator is currently just a trick
  IteratorOnLines &end() {
    return *this;
  }

  IteratorOnLines &operator++() {
    start = ++next;
    next = input_raw.find(delimiter, start);
    line = std::string_view{input_raw.data() + start, next - start};
    return *this;
  }

  reference operator*() {
    return line;
  }

  bool operator!=(const IteratorOnLines &b) {
    // Ugly trick, we assume the check condition will always be vs the end iterator.
    // So we don't need to create a real end iterator we just check vs string_view end index
    return this->next != std::string_view::npos;
  };

private:
  std::string_view input_raw;
  char delimiter;
  // We have to store the current line otherwise we can't give it as a reference
  std::string_view line;
  size_t start = 0;
  size_t next = 0;
};

} // namespace

// We read the whole file in a string
// We use an iterator implementation that was a bit tricky/ugly
// but we have a nice syntaxe and full speed
int main(int argc, char *argv[]) {
  if (argc <= 1)
    return 1;

  auto start_temp = std::chrono::high_resolution_clock::now();
  uint64_t part1 = 0;
  uint64_t part2 = 0;
  constexpr float nruns = 10000.;
  for (int i = 0; i < nruns; ++i) {

    const std::string input_raw = ReadToString(argv[1]);

    int acc_part1 = 0;
    int acc_part2 = 0;
    const std::array<std::string_view, 9> digits_string{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

    for (auto line : IteratorOnLines(input_raw)) {
      // part 1
      {
        int firstDigit = 0;
        int lastDigit = 0;
        // forward
        for (int i = 0; i < line.size(); ++i) {
          if (const int digit = line[i] - '0'; digit >= 0 && digit < 10) {
            firstDigit = digit;
            break;
          }
        }
        // backward
        for (int i = line.size() - 1; i >= 0; --i) {
          if (const int digit = line[i] - '0'; digit >= 0 && digit < 10) {
            lastDigit = digit;
            break;
          }
        }
        acc_part1 += firstDigit * 10 + lastDigit;
      }
      // part2
      {
        int firstDigit = 0;
        int lastDigit = 0;
        // forward
        for (int i = 0; i < line.size(); ++i) {
          const auto slice = line.substr(i);
          if (const int digit = slice[0] - '0'; digit >= 0 && digit < 10) {
            firstDigit = digit;
            break;
          } else {
            for (int idx = 0; idx < digits_string.size(); ++idx) {
              if (slice.starts_with(digits_string[idx])) {
                firstDigit = idx + 1;
                goto endforward;  // Don't do that at home, I'm too lazy to create function
              }
            }
          }
        }
        endforward:
        // backward
        for (int i = line.size() - 1; i >= 0; --i) {
          const auto slice = line.substr(i);
          if (const int digit = slice[0] - '0'; digit >= 0 && digit < 10) {
            lastDigit = digit;
            break;
          } else {
            for (int idx = 0; idx < digits_string.size(); ++idx) {
              if (slice.starts_with(digits_string[idx])) {
                lastDigit = idx + 1;
                goto endbackward;
              }
            }
          }
        }
        endbackward:
        acc_part2 += firstDigit * 10 + lastDigit;
      }
    };

    part1 = acc_part1;
    part2 = acc_part2;
  }

  std::chrono::duration<double, std::micro> elapsed_temp = std::chrono::high_resolution_clock::now() - start_temp;
  std::cout << "info: C++  day01 in \t\t" << elapsed_temp.count() / nruns << " us : part1=" << part1 << " \tpart2=" << part2 << std::endl;

  return 0;
}
