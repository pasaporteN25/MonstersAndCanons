class_name WearRules
extends RefCounted

static func impact(current: float, amount: float, maximum: float) -> float:
	return clampf(current + maxf(0.0,amount),0.0,clampf(maximum,0.0,100.0))

static func ratio(wear: float) -> float:
	return 1.0 - clampf(wear,0.0,100.0) / 100.0

static func repair(current: float, rate: float, delta: float) -> float:
	return maxf(0.0,current - maxf(0.0,rate) * maxf(0.0,delta))
