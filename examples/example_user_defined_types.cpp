#include "quill/Quill.h"
#include "quill/Utility.h"
#include <cstdint>
#include <string>

/**
 * A user defined type
 */
class User
{
public:
  User(std::string name, std::string surname, uint32_t age)
    : name(std::move(name)), surname(std::move(surname)), age(age){};

  friend std::ostream& operator<<(std::ostream& os, User const& obj)
  {
    os << "name : " << obj.name << ", surname: " << obj.surname << ", age: " << obj.age;
    return os;
  }

private:
  std::string name;
  std::string surname;
  uint32_t age;
};

template <> struct fmt::formatter<User> : ostream_formatter {};

/**
 * An other user defined type that is marked as safe to copy
 */
class User2
{
public:
  User2(std::string name, std::string surname, uint32_t age)
    : name(std::move(name)), surname(std::move(surname)), age(age){};

  friend std::ostream& operator<<(std::ostream& os, User2 const& obj)
  {
    os << "name : " << obj.name << ", surname: " << obj.surname << ", age: " << obj.age;
    return os;
  }

  /**
   * This class is tagged as safe to copy and it does not have to be formatted on the hot path
   * anymore
   */
  QUILL_COPY_LOGGABLE;

private:
  std::string name;
  std::string surname;
  uint32_t age;
};

template <> struct fmt::formatter<User2> : ostream_formatter {};

/**
 * An other user defined type that is registered as safe to copy via copy_logable
 */
class User3
{
public:
  User3(std::string name, std::string surname, uint32_t age)
    : name(std::move(name)), surname(std::move(surname)), age(age){};

  friend std::ostream& operator<<(std::ostream& os, User3 const& obj)
  {
    os << "name : " << obj.name << ", surname: " << obj.surname << ", age: " << obj.age;
    return os;
  }

private:
  std::string name;
  std::string surname;
  uint32_t age;
};

template <> struct fmt::formatter<User3> : ostream_formatter {};

/**
 * Specialise copy_loggable to register User3 object as safe to copy.
 */
namespace quill
{
template <>
struct copy_loggable<User3> : std::true_type
{
};
} // namespace quill

int main()
{
  // Assuming QUILL_MODE_UNSAFE was NOT defined
  quill::start();

  User usr{"James", "Bond", 32};

  // The following fails to compile
  // LOG_INFO(quill::get_logger(), "The user is {}", usr);

  // The user has to explicitly format on the hot path
  LOG_INFO(quill::get_logger(), "The user is {}", quill::utility::to_string(usr));

  // The following compiles and logs, because the object is tagged by the user as safe
  User2 tagged_user{"James", "Bond", 32};
  LOG_INFO(quill::get_logger(), "The user is {}", tagged_user);

  // The following compiles and logs, because the object is registered by the user as safe
  User3 registred_user{"James", "Bond", 42};
  LOG_INFO(quill::get_logger(), "The user is {}", registred_user);
}