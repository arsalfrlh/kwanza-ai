import json
import ast
import math
import statistics
from decimal import Decimal, ROUND_HALF_UP

class SafeCalculator:
    ALLOWED_FUNCTIONS = {
        # Basic
        "abs": abs,
        "round": round,
        "min": min,
        "max": max,

        # Math
        "sqrt": math.sqrt,
        "cbrt": lambda x: x ** (1 / 3),
        "root": lambda x, n: x ** (1 / n),
        "pow": pow,
        "exp": math.exp,
        "ln": math.log,
        "log": math.log,
        "log10": math.log10,
        "log2": math.log2,
        "floor": math.floor,
        "ceil": math.ceil,

        # Trigonometry - radians
        "sin": math.sin,
        "cos": math.cos,
        "tan": math.tan,
        "asin": math.asin,
        "acos": math.acos,
        "atan": math.atan,

        # Angle conversion
        "radians": math.radians,
        "degrees": math.degrees,

        # Trigonometry - degrees
        "sin_deg": lambda x: math.sin(math.radians(x)),
        "cos_deg": lambda x: math.cos(math.radians(x)),
        "tan_deg": lambda x: math.tan(math.radians(x)),

        # Statistics
        "mean": statistics.mean,
        "median": statistics.median,
        "variance": statistics.variance,
        "stdev": statistics.stdev,

        # Combinatorics
        "factorial": math.factorial,
        "combinations": math.comb,
        "permutations": math.perm,

        # Number theory
        "gcd": math.gcd,
        "lcm": math.lcm,

        # Finance / percentage
        "percent": lambda x: x / 100,
        "percent_of": lambda percent, value: (percent / 100) * value,

        "percentage_change":
            lambda old, new: ((new - old) / old) * 100,

        "discount":
            lambda price, percent: price - ((percent / 100) * price),

        "tax":
            lambda price, percent: price + ((percent / 100) * price),

        "tip":
            lambda bill, percent: bill + ((percent / 100) * bill),

        "simple_interest":
            lambda principal, rate, years:
                principal * (rate / 100) * years,

        "simple_interest_total":
            lambda principal, rate, years:
                principal + (principal * (rate / 100) * years),

        "compound_interest":
            lambda principal, rate, years:
                principal * ((1 + rate / 100) ** years),

        "compound_interest_only":
            lambda principal, rate, years:
                principal * ((1 + rate / 100) ** years) - principal,

        "cagr":
            lambda beginning, ending, years:
                ((ending / beginning) ** (1 / years) - 1) * 100,

        "loan_payment":
            lambda principal, annual_rate, years:
                (
                    principal
                    * (
                        (annual_rate / 100 / 12)
                        * (
                            1 + annual_rate / 100 / 12
                        ) ** (years * 12)
                    )
                    /
                    (
                        (
                            1 + annual_rate / 100 / 12
                        ) ** (years * 12)
                        - 1
                    )
                ),
    }

    CONSTANTS = {
        "pi": math.pi,
        "e": math.e,
        "tau": math.tau,
        "inf": math.inf,
    }

    ALLOWED_BIN_OPS = {
        ast.Add: lambda a, b: a + b,
        ast.Sub: lambda a, b: a - b,
        ast.Mult: lambda a, b: a * b,
        ast.Div: lambda a, b: a / b,
        ast.FloorDiv: lambda a, b: a // b,
        ast.Mod: lambda a, b: a % b,
        ast.Pow: lambda a, b: a ** b,
    }

    ALLOWED_UNARY_OPS = {
        ast.UAdd: lambda a: +a,
        ast.USub: lambda a: -a,
    }

    def calculate(self, expression: str):
        expression = expression.strip()

        if not expression:
            raise ValueError("Expression cannot be empty.")

        if len(expression) > 500:
            raise ValueError("Expression is too long.")

        try:
            tree = ast.parse(expression, mode="eval")

            result = self._evaluate(tree.body)

            if isinstance(result, float):
                if math.isnan(result):
                    raise ValueError("Result is NaN.")

                if math.isinf(result):
                    raise ValueError("Result is infinite.")

                # Avoid ugly floating point artifacts
                result = round(result, 12)

            return {
                "success": True,
                "expression": expression,
                "result": result
            }

        except ZeroDivisionError:
            return {
                "success": False,
                "expression": expression,
                "error": "Division by zero."
            }

        except (ValueError, TypeError, OverflowError) as e:
            return {
                "success": False,
                "expression": expression,
                "error": str(e)
            }

        except Exception as e:
            return {
                "success": False,
                "expression": expression,
                "error": f"Invalid expression: {str(e)}"
            }

    def _evaluate(self, node):

        # Number
        if isinstance(node, ast.Constant):
            if isinstance(node.value, (int, float)):
                return node.value

            if isinstance(node.value, list):
                return node.value

            raise ValueError("Unsupported constant.")

        # List
        if isinstance(node, ast.List):
            return [
                self._evaluate(element)
                for element in node.elts
            ]

        # Binary operation
        if isinstance(node, ast.BinOp):
            operator_type = type(node.op)

            if operator_type not in self.ALLOWED_BIN_OPS:
                raise ValueError(
                    f"Operator {operator_type.__name__} is not allowed."
                )

            left = self._evaluate(node.left)
            right = self._evaluate(node.right)

            # Protect against extremely huge powers
            if operator_type is ast.Pow:
                if abs(right) > 1000:
                    raise ValueError(
                        "Exponent is too large."
                    )

            return self.ALLOWED_BIN_OPS[operator_type](
                left,
                right
            )

        # Unary
        if isinstance(node, ast.UnaryOp):
            operator_type = type(node.op)

            if operator_type not in self.ALLOWED_UNARY_OPS:
                raise ValueError(
                    f"Unary operator {operator_type.__name__} is not allowed."
                )

            operand = self._evaluate(node.operand)

            return self.ALLOWED_UNARY_OPS[operator_type](
                operand
            )

        # Function call
        if isinstance(node, ast.Call):

            if not isinstance(node.func, ast.Name):
                raise ValueError(
                    "Only direct function calls are allowed."
                )

            function_name = node.func.id

            if function_name not in self.ALLOWED_FUNCTIONS:
                raise ValueError(
                    f"Function '{function_name}' is not allowed."
                )

            function = self.ALLOWED_FUNCTIONS[function_name]

            args = [
                self._evaluate(arg)
                for arg in node.args
            ]

            # keyword arguments are intentionally disabled
            if node.keywords:
                raise ValueError(
                    "Keyword arguments are not supported."
                )

            return function(*args)

        # Variable/constants
        if isinstance(node, ast.Name):

            if node.id in self.CONSTANTS:
                return self.CONSTANTS[node.id]

            raise ValueError(
                f"Unknown variable '{node.id}'."
            )

        raise ValueError(
            f"Unsupported expression: {type(node).__name__}"
        )