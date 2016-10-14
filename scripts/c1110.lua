--松本りせ
--①：自分フィールド上に「ゆるゆり」キャラクターが表側表示で存在する場合、このカードは手札から特殊召喚する事ができる。
--②：魔法・罠・モンスターの効果が発動した時、このカードを手札に戻して発動できる。その発動を無効にし破壊する。

function c1110.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1110, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1110.e1condition)
	c:RegisterEffect(e1)

	--Activate
	local e2 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1110.e2condition)
	e2:SetTarget(c1110.e2target)
	e2:SetOperation(c1110.e2operation)
	c:RegisterEffect(e2)

end

-- ゆるゆりキャラフィルター
function c1110.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつゆるゆりキャラ(=0x186A0)か
	return c:IsFaceup() and c:IsSetCard(0x186A0)
end

function c1110.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1110.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

function c1110.e2condition(e, tp, eg, ep, ev, re, r, rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp ~= tp and Duel.IsChainNegatable(ev)
end

function c1110.e2target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
end

function c1110.e2operation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg, REASON_EFFECT)
	end
	Duel.SendtoHand(c, nil, REASON_EFFECT)
end
